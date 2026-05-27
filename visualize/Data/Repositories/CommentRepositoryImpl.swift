//
//  CommentRepositoryImpl.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//

import Foundation
import FirebaseCore

/// Concrete comment repository that persists snip comments through the comment datasource.
final class CommentRepositoryImpl: CommentRepository {

    private let commentDatasource: CommentDatasource
    private var userCache: [String: AppUser] = [:]

    init(commentDatasource: CommentDatasource = CommentDatasource()) {
        self.commentDatasource = commentDatasource
    }

    func postSnipComment(visualizationID: String, authorID: String, imageURL: URL, authorName: String) async throws {
        try await commentDatasource.postSnipComment(
            visualizationID: visualizationID,
            authorID: authorID,
            imageURL: imageURL,
            authorName: authorName
        )
    }
    
    // MARK: - Comments

    func loadComments(visualizationID: String) async throws -> [Comment] {
        let dtos = try await commentDatasource.fetchComments(visualizationID: visualizationID)

        var comments: [Comment] = []

        await withTaskGroup(of: Comment.self) { group in
            for dto in dtos {
                group.addTask {
                    let threads = await self.loadThreads(
                        visualizationID: visualizationID,
                        commentID: dto.id ?? ""
                    )
                    let (authorName, avatarURL) = await self.resolveUserInfo(userID: dto.authorID, storedName: dto.authorName)
                    return dto.toComment(threads: threads, resolvedAuthorName: authorName, resolvedAvatarURL: avatarURL)
                }
            }
            for await comment in group {
                comments.append(comment)
            }
        }

        return comments.sorted { $0.createdAt.dateValue() < $1.createdAt.dateValue() }
    }

    func postComment(visualizationID: String, author: AppUser, content: String, imageURL: String? = nil) async throws {
        try await commentDatasource.postComment(
            visualizationID: visualizationID,
            authorID: author.id,
            authorName: author.username,
            content: content,
            imageURL: imageURL
        )
    }

    func deleteComment(visualizationID: String, commentID: String) async throws {
        try await commentDatasource.deleteComment(
            visualizationID: visualizationID,
            commentID: commentID
        )
    }

    // MARK: - Threads

    func postReply(visualizationID: String, commentID: String, author: AppUser, content: String) async throws {
        try await commentDatasource.postReply(
            visualizationID: visualizationID,
            commentID: commentID,
            authorID: author.id,
            authorName: author.username,
            authorAvatarURL: author.profilePictureURL,
            content: content
        )
    }

    func deleteReply(visualizationID: String, commentID: String, replyID: String) async throws {
        try await commentDatasource.deleteReply(
            visualizationID: visualizationID,
            commentID: commentID,
            replyID: replyID
        )
    }

    // MARK: - Private

    private func loadThreads(visualizationID: String, commentID: String) async -> [ThreadReply] {
        guard !commentID.isEmpty else { return [] }
        do {
            let dtos = try await commentDatasource.fetchThreads(
                visualizationID: visualizationID,
                commentID: commentID
            )
            return await withTaskGroup(of: ThreadReply.self) { group in
                for dto in dtos {
                    group.addTask {
                        let (name, avatar) = await self.resolveUserInfo(
                            userID: dto.authorID,
                            storedName: dto.authorName
                        )
                        return await dto.toThreadReply(
                            resolvedAuthorName: name,
                            resolvedAvatarURL: avatar
                        )
                    }
                }
                var replies: [ThreadReply] = []
                for await reply in group {
                    replies.append(reply)
                }
                return replies.sorted { $0.createdAt.dateValue() < $1.createdAt.dateValue() }
            }
        } catch {
            return []
        }
    }

    private func resolveUsername(userID: String) async -> String? {
        if let cached = userCache[userID] { return cached.username }
        guard let data = try? await commentDatasource.fetchUser(userID: userID),
              let username = data["username"] as? String else { return nil }
        return username
    }

    private func resolveUserInfo(userID: String, storedName: String?) async -> (String, String?) {
        if let cached = userCache[userID] {
            return (cached.username, cached.profilePictureURL)
        }

        // Fetch from Firestore
        guard let data = try? await commentDatasource.fetchUser(userID: userID) else {
            return (storedName ?? "Unknown", nil)
        }

        let username = data["username"] as? String ?? storedName ?? "Unknown"
        let avatar = data["profilePictureURL"] as? String

        // Save to cache
        userCache[userID] = AppUser(
            id: userID,
            email: data["email"] as? String ?? "",
            profilePictureURL: avatar,
            username: username
        )

        return (username, avatar)
    }
}
