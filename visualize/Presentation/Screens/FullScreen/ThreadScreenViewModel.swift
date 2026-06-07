//
//  ThreadsViewModel.swift
//  visualize
//
//  Created by Kimberly Marquez on 03/05/26.
//
//  Manages comments and thread replies for a visualization.
//  Delegates all business logic to Use Cases.

import Foundation
import Observation

@MainActor
@Observable
class ThreadScreenViewModel {

    // MARK: - Properties

    var comments: [Comment] = []
    var isLoading = false
    var error: String?
    var currentUser: AppUser?
    var permissions: ThreadPermissions? {
        guard let user = currentUser else { return nil }
        return ThreadPermissions(
            currentUserRole: user.role,
            currentUserID: user.id,
            visualizationOwnerID: visualizationOwnerID
        )
    }

    private let visualizationID: String
    private let isPreview: Bool
    private let repository: CommentRepository
    private let userRepository: UserRepository
    private let authRepository: any AuthRepository
    private let postCommentUseCase: PostCommentUseCase
    private let postReplyUseCase: PostReplyUseCase
    private let deleteCommentUseCase: DeleteCommentUseCase
    private let deleteReplyUseCase: DeleteReplyUseCase
    private let visualizationOwnerID: String
    
    // MARK: - Init

    init(
        visualizationID: String,
        visualizationOwnerID: String,
        isPreview: Bool = false,
        repository: CommentRepository,
        userRepository: UserRepository,
        authRepository: any AuthRepository,
        postCommentUseCase: PostCommentUseCase,
        postReplyUseCase: PostReplyUseCase,
        deleteCommentUseCase: DeleteCommentUseCase,
        deleteReplyUseCase: DeleteReplyUseCase
    ) {
        self.visualizationID = visualizationID
        self.visualizationOwnerID = visualizationOwnerID
        self.isPreview = isPreview
        self.repository = repository
        self.userRepository = userRepository
        self.authRepository = authRepository
        self.postCommentUseCase = postCommentUseCase
        self.postReplyUseCase = postReplyUseCase
        self.deleteCommentUseCase = deleteCommentUseCase
        self.deleteReplyUseCase = deleteReplyUseCase
    }

    #if DEBUG
    static func preview() -> ThreadScreenViewModel {
        let mockCommentRepo = CommentRepositoryImpl()
        let mockUserRepo = UserRepositoryImpl(userDatasource: UserDatasource())
        let mockAuthRepo = AuthRepositoryImpl(source: AuthFirebaseDatasource())
        
        let vm = ThreadScreenViewModel(
            visualizationID: "preview",
            visualizationOwnerID: "preview",
            isPreview: true,
            repository: mockCommentRepo,
            userRepository: mockUserRepo,
            authRepository: mockAuthRepo,
            postCommentUseCase: PostCommentUseCase(),
            postReplyUseCase: PostReplyUseCase(),
            deleteCommentUseCase: DeleteCommentUseCase(),
            deleteReplyUseCase: DeleteReplyUseCase()
        )
        
        vm.comments = [
            Comment(
                id: "c1",
                authorID: "u1",
                authorName: "Kimberly Marquez",
                content: "This is a test comment",
                imageURL: nil,
                createdAt: Date(),
                threads: [
                    ThreadReply(
                        id: "r1",
                        authorID: "u1",
                        authorName: "Diana Escalante",
                        authorAvatarURL: nil,
                        createdAt: Date(),
                        content: "This is a test reply",
                    )
                ],
            )
        ]
        return vm
    }
    #endif

    // MARK: - Public Methods
    
    func fetchCurrentUser() async {
        guard !isPreview else { return }
        do {
            let userID = try await authRepository.getCurrentUserID()
            currentUser = try await userRepository.getUserByID(userID: userID)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadComments() async {
        guard !isPreview else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            comments = try await repository.loadComments(visualizationID: visualizationID)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func postComment(content: String) async {
        guard let user = currentUser else { return }
        do {
            try await postCommentUseCase.execute(
                visualizationID: visualizationID,
                author: user,
                content: content
            )
            await appendNewComments()
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Posts a reply under the given comment and refreshes the comments list.
    func postReply(to commentID: String, content: String) async {
        guard let user = currentUser else { return }
        do {
            try await postReplyUseCase.execute(
                visualizationID: visualizationID,
                commentID: commentID,
                author: user,
                content: content
            )
            await refreshComment(commentID: commentID)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deleteComment(commentID: String, authorID: String) async {
        guard let user = currentUser else { return }
        do {
            try await deleteCommentUseCase.execute(
                visualizationID: visualizationID,
                commentID: commentID,
                requestingUserID: user.id,
                authorID: authorID
            )
            comments.removeAll { $0.id == commentID }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deleteReply(commentID: String, replyID: String, authorID: String) async {
        guard let user = currentUser else { return }
        do {
            try await deleteReplyUseCase.execute(
                visualizationID: visualizationID,
                commentID: commentID,
                replyID: replyID,
                requestingUserID: user.id,
                authorID: authorID
            )
            if let index = comments.firstIndex(where: { $0.id == commentID }) {
                comments[index].threads.removeAll { $0.id == replyID }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func appendNewComments() async {
        do {
            let all = try await repository.loadComments(visualizationID: visualizationID)
            let existingIDs = Set(comments.map { $0.id })
            let newComments = all.filter { !existingIDs.contains($0.id) }
            comments.append(contentsOf: newComments)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func refreshComment(commentID: String) async {
        do {
            let all = try await repository.loadComments(visualizationID: visualizationID)
            if let updated = all.first(where: { $0.id == commentID }),
               let index = comments.firstIndex(where: { $0.id == commentID }) {
                comments[index] = updated
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
}
