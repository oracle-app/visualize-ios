//
//  ThreadsViewModel.swift
//  visualize
//
//  Created by Kimberly Marquez on 03/05/26.
//

import Foundation
import FirebaseFirestore
import Observation

@Observable
class ThreadsViewModel {

    var comments: [Comment] = []
    var isLoading = false

    private let db = Firestore.firestore()
    private let visualizationID: String

    // Cache local de usuarios para evitar múltiples reads repetidos
    private var userCache: [String: AppUser] = [:]

    init(visualizationID: String) {
        self.visualizationID = visualizationID
    }

    // MARK: - Load Comments + Threads
    func loadComments() async {
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

            comments = loaded
        } catch {
            print("Error cargando comments: \(error)")
        }
    }

    // MARK: - Load Threads
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
            print("Error cargando threads: \(error)")
            return []
        }
    }

    // MARK: - Post Reply
    func postReply(to commentID: String, content: String, author: AppUser) async {
        let data: [String: Any] = [
            "authorID": author.id ?? "",
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

            await loadComments()
        } catch {
            print("Error posteando reply: \(error)")
        }
    }

    // MARK: - User Enrichment / Cache
    private func enrichWithUser(reply: ThreadReply) async -> ThreadReply {
        var enriched = reply

        // Si ya viene duplicado desde Firestore, úsalo directamente
        if !enriched.authorName.isEmpty {
            enriched.timeAgo = reply.createdAt.dateValue().timeAgoDisplay()
            return enriched
        }

        // Cache local
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
