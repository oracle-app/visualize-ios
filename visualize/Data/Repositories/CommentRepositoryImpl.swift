//
//  CommentRepositoryImpl.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//
//
//  Data-layer `CommentRepository` implementation used by the Snipping Tool share
//  flow and comment threads. It composes `CommentDatasource` + `UserDatasource`
//  and resolves author info when mapping Firestore DTOs into domain models.

import Foundation
import FirebaseCore

/// Concrete comment repository that persists snip comments through the comment datasource.
final class CommentRepositoryImpl: CommentRepository {

    private let commentDatasource: CommentDatasource
    private let userDatasource: UserDatasource
    private var userCache: [String: AppUser] = [:]

    init(
        commentDatasource: CommentDatasource = CommentDatasource(),
        userDatasource: UserDatasource = UserDatasource()
    ) {
        self.commentDatasource = commentDatasource
        self.userDatasource = userDatasource
    }

    func postSnipComment(
        visualizationID: String,
        authorID: String,
        imageURL: URL,
        authorName: String,
        caption: String?
    ) async throws {
        try await commentDatasource.postSnipComment(
            visualizationID: visualizationID,
            authorID: authorID,
            imageURL: imageURL,
            authorName: authorName,
            caption: caption
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
                    let (authorName, avatarURL) = await self.resolveUserInfo(userID: dto.authorID)
                    return dto.toComment(
                        threads: threads,
                        resolvedAuthorName: authorName,
                        resolvedAvatarURL: avatarURL
                    )
                }
            }
            for await comment in group {
                comments.append(comment)
            }
        }

        return comments.sorted { $0.createdAt < $1.createdAt }
    }

    func postComment(visualizationID: String, author: AppUser, content: String, imageURL: String? = nil) async throws {
        try await commentDatasource.postComment(
            visualizationID: visualizationID,
            authorID: author.id,
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
                        let (authorName, avatarURL) = await self.resolveUserInfo(userID: dto.authorID)
                        return dto.toThreadReply(
                            resolvedAuthorName: authorName,
                            resolvedAvatarURL: avatarURL
                        )
                    }
                }
                var replies: [ThreadReply] = []
                for await reply in group {
                    replies.append(reply)
                }
                return replies.sorted { $0.createdAt < $1.createdAt }
            }
        } catch {
            return []
        }
    }

    private func resolveUserInfo(userID: String) async -> (String, String?) {
        if let cached = userCache[userID] {
            return (cached.username, cached.profilePictureURL)
        }
        guard let user = try? await userDatasource.getUserByID(userID: userID).toAppUser() else {
            return ("Unknown", nil)
        }
        userCache[userID] = user
        return (user.username, user.profilePictureURL)
    }
}
