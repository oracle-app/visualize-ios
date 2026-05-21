//
//  ThreadsViewModel.swift
//  visualize
//
//  Created by Kimberly Marquez on 03/05/26.
//
//  Manages comments and thread replies for a visualization.
//  - Loads comments and nested replies from Firestore in parallel
//  - Posts new replies and refreshes the comments list
//  - Caches user data to avoid redundant Firestore fetches
//  - Enriches replies with author info and relative timestamps

import Foundation
import FirebaseFirestore
import Observation

@MainActor
@Observable
class ThreadsViewModel {

    // MARK: - Properties

    var comments: [Comment] = []
    var isLoading = false
    var threadError: String?

    private let db = Firestore.firestore()
    private let visualizationID: String
    private let isPreview: Bool
    private var userCache: [String: AppUser] = [:]

    // MARK: - Init

    init(visualizationID: String, isPreview: Bool = false) {
        self.visualizationID = visualizationID
        self.isPreview = isPreview
    }

    #if DEBUG
    static func preview() -> ThreadsViewModel {
        let vm = ThreadsViewModel(visualizationID: "preview", isPreview: true)
        vm.comments = [
            Comment(
                id: "c1",
                authorID: "Kimberly Marquez",
                authorName: "Kimberly Marquez",
                content: "Este es un comentario de prueba",
                createdAt: Timestamp(date: Date()),
                threads: [
                    ThreadReply(
                        id: "r1",
                        authorID: "u1",
                        authorName: "Diana Escalante",
                        authorAvatarURL: "",
                        createdAt: Timestamp(date: Date()),
                        content: "Este es un reply de prueba",
                        timeAgo: "5 min ago"
                    )
                ]
            )
        ]
        return vm
    }
    #endif

    // MARK: - Public Methods

    /// Loads all comments and their thread replies for the current visualization.
    func loadComments() async {
        guard !isPreview else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await db
                .collection("visualizations")
                .document(visualizationID)
                .collection("comments")
                .order(by: "createdAt", descending: false)
                .getDocuments()

            var loaded: [Comment] = snapshot.documents.compactMap {
                try? $0.data(as: Comment.self)
            }

            // Enrich threads and author names in parallel
            await withTaskGroup(of: (Int, [ThreadReply]).self) { group in
                for i in loaded.indices {
                    guard let commentID = loaded[i].id else { continue }
                    group.addTask {
                        let threads = await self.loadThreads(commentID: commentID)
                        return (i, threads)
                    }
                }
                for await (index, threads) in group {
                    loaded[index].threads = threads
                }
            }

            // Enrich comment author names after threads are loaded
            for i in loaded.indices {
                loaded[i] = await enrichCommentAuthor(comment: loaded[i])
            }

            comments = loaded
        } catch {
            threadError = error.localizedDescription
        }
    }

    /// Posts a reply under the given comment and refreshes the comments list.
    func postReply(to commentID: String, content: String, author: AppUser) async {
        let data: [String: Any] = [
            "authorID": author.id,
            "authorName": author.username,
            "authorAvatarURL": author.profilePictureURL ?? "",
            "content": content,
            "createdAt": Timestamp()
        ]

        do {
            try await db
                .collection("visualizations")
                .document(visualizationID)
                .collection("comments")
                .document(commentID)
                .collection("threads")
                .addDocument(data: data)
        } catch {
            threadError = error.localizedDescription
        }
    }

    // MARK: - Private Methods

    /// Fetches and enriches all thread replies for a given comment.
    private func loadThreads(commentID: String) async -> [ThreadReply] {
        do {
            let snapshot = try await db
                .collection("visualizations")
                .document(visualizationID)
                .collection("comments")
                .document(commentID)
                .collection("threads")
                .order(by: "createdAt", descending: false)
                .getDocuments()

            var replies: [ThreadReply] = snapshot.documents.compactMap {
                try? $0.data(as: ThreadReply.self)
            }

            await withTaskGroup(of: (Int, ThreadReply).self) { group in
                for i in replies.indices {
                    group.addTask {
                        let enriched = await self.enrichWithUser(reply: replies[i])
                        return (i, enriched)
                    }
                }
                for await (index, enrichedReply) in group {
                    replies[index] = enrichedReply
                }
            }

            return replies
        } catch {
            threadError = error.localizedDescription
            return []
        }
    }

    /// Resolves the author name for a comment from Firestore, using the cache when possible.
    private func enrichCommentAuthor(comment: Comment) async -> Comment {
        var updated = comment

        // If Firestore already stored a real authorName (not a UID), just use it
        if let name = comment.authorName, !name.isEmpty, name != comment.authorID, name.contains(" ") || name.count < 30 {
            return updated
        }

        if let cached = userCache[comment.authorID] {
            updated.authorName = cached.username
            return updated
        }

        do {
            let doc = try await db
                .collection("users")
                .document(comment.authorID)
                .getDocument()
            if let username = doc.data()?["username"] as? String, !username.isEmpty {
                updated.authorName = username
            }
        } catch {
            updated.authorName = nil
        }

        return updated
    }

    /// Fills in author info and relative timestamp on a reply, using the cache when possible.
    private func enrichWithUser(reply: ThreadReply) async -> ThreadReply {
        var enriched = reply

        if !enriched.authorName.isEmpty {
            enriched.timeAgo = reply.createdAt.dateValue().timeAgoDisplay()
            return enriched
        }

        if let cachedUser = userCache[reply.authorID] {
            enriched.authorName = cachedUser.username
            enriched.authorAvatarURL = cachedUser.profilePictureURL
            enriched.timeAgo = reply.createdAt.dateValue().timeAgoDisplay()
            return enriched
        }

        do {
            let doc = try await db
                .collection("users")
                .document(reply.authorID)
                .getDocument()
            let user = try doc.data(as: AppUser.self)
            userCache[reply.authorID] = user
            enriched.authorName = user.username
            enriched.authorAvatarURL = user.profilePictureURL
            enriched.timeAgo = reply.createdAt.dateValue().timeAgoDisplay()
        } catch {
            enriched.authorName = "Unknown"
        }

        return enriched
    }
}

// MARK: - Date Extension

extension Date {
    func timeAgoDisplay() -> String {
        let seconds = Int(Date().timeIntervalSince(self))
        switch seconds {
        case ..<60: return "just now"
        case ..<3600: return "\(seconds / 60) min ago"
        case ..<86400: return "\(seconds / 3600) hr ago"
        default: return "\(seconds / 86400) days ago"
        }
    }
}
