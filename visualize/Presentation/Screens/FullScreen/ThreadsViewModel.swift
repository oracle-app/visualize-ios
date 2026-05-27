//
//  ThreadsViewModel.swift
//  visualize
//
//  Created by Kimberly Marquez on 03/05/26.
//
//  Manages comments and thread replies for a visualization.
//  Delegates all business logic to Use Cases.

import Foundation
import FirebaseFirestore
import Observation

@MainActor
@Observable
class ThreadsViewModel {

    // MARK: - Properties

    var comments: [Comment] = []
    var isLoading = false
    var error: String?

    private let visualizationID: String
    private let isPreview: Bool
    private let loadCommentsUseCase: LoadCommentsUseCase
    private let postCommentUseCase: PostCommentUseCase
    private let postReplyUseCase: PostReplyUseCase
    private let deleteCommentUseCase: DeleteCommentUseCase
    private let deleteReplyUseCase: DeleteReplyUseCase
    
    // MARK: - Init

    init(
        visualizationID: String,
        isPreview: Bool = false,
        loadCommentsUseCase: LoadCommentsUseCase? = nil,
        postCommentUseCase: PostCommentUseCase? = nil,
        postReplyUseCase: PostReplyUseCase? = nil,
        deleteCommentUseCase: DeleteCommentUseCase? = nil,
        deleteReplyUseCase: DeleteReplyUseCase? = nil
    ) {
        self.visualizationID = visualizationID
        self.isPreview = isPreview
        self.loadCommentsUseCase = loadCommentsUseCase ?? LoadCommentsUseCase()
        self.postCommentUseCase = postCommentUseCase ?? PostCommentUseCase()
        self.postReplyUseCase = postReplyUseCase ?? PostReplyUseCase()
        self.deleteCommentUseCase = deleteCommentUseCase ?? DeleteCommentUseCase()
        self.deleteReplyUseCase = deleteReplyUseCase ?? DeleteReplyUseCase()
    }

    #if DEBUG
    static func preview() -> ThreadsViewModel {
        let vm = ThreadsViewModel(visualizationID: "preview", isPreview: true)
        vm.comments = [
            Comment(
                id: "c1",
                authorID: "u1",
                authorName: "Kimberly Marquez",
                content: "This is a test comment",
                imageURL: nil,
                createdAt: .init(date: .now),
                threads: [
                    ThreadReply(
                        id: "r1",
                        authorID: "u1",
                        authorName: "Diana Escalante",
                        authorAvatarURL: nil,
                        createdAt: .init(date: .now),
                        content: "This is a test reply",
                        timeAgo: "5 min ago"
                    )
                ],
                timeAgo: "just now"
            )
        ]
        return vm
    }
    #endif

    // MARK: - Public Methods

    func loadComments() async {
        guard !isPreview else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            comments = try await loadCommentsUseCase.execute(visualizationID: visualizationID)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func postComment(content: String, author: AppUser) async {
        do {
            try await postCommentUseCase.execute(
                visualizationID: visualizationID,
                author: author,
                content: content
            )
            await loadComments()
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Posts a reply under the given comment and refreshes the comments list.
    func postReply(to commentID: String, content: String, author: AppUser) async {
        do {
            try await postReplyUseCase.execute(
                visualizationID: visualizationID,
                commentID: commentID,
                author: author,
                content: content
            )
            await loadComments()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deleteComment(commentID: String, authorID: String, currentUserID: String) async {
        do {
            try await deleteCommentUseCase.execute(
                visualizationID: visualizationID,
                commentID: commentID,
                requestingUserID: currentUserID,
                authorID: authorID
            )
            await loadComments()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deleteReply(commentID: String, replyID: String, authorID: String, currentUserID: String) async {
        do {
            try await deleteReplyUseCase.execute(
                visualizationID: visualizationID,
                commentID: commentID,
                replyID: replyID,
                requestingUserID: currentUserID,
                authorID: authorID
            )
            await loadComments()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
