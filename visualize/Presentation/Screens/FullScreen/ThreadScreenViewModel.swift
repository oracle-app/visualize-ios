//
//  ThreadsViewModel.swift
//  visualize
//
//  Created by Kimberly Marquez on 03/05/26.
//
///  Manages the state and business logic for the Threads screen.
///
///  Responsibilities:
///  - Loads comments and their nested replies for a given visualization.
///  - Posts new text-only threads and image-based snip comments.
///  - Posts replies to existing threads.
///  - Deletes comments and replies based on user permissions.
///  - Resolves the current authenticated user and builds permission context.
///  - Performs partial UI updates: appends new comments without a full reload,
///    and refreshes only the affected comment after a reply is posted.
///
///  This ViewModel delegates all data operations to injected Use Cases and
///  Repositories, keeping it free of Firebase or infrastructure dependencies.


import Foundation
import Observation

@MainActor
@Observable
class ThreadScreenViewModel {

    // MARK: - Properties
    
    /// The list of comments currently displayed in the Threads screen.
    var comments: [Comment] = []
    /// Indicates whether a comment load operation is in progress.
    var isLoading = false
    /// Holds a localized error message when any operation fails.
    /// Observed by the view to present an alert.
    var error: String?
    /// The authenticated user currently using the app.
    /// Populated by `fetchCurrentUser()` on screen appear.
    var currentUser: AppUser?
    /// Derived permission context for the current user and visualization.
    /// `nil` until `currentUser` is resolved.
    var permissions: ThreadPermissions? {
        guard let user = currentUser else { return nil }
        return ThreadPermissions(
            currentUserRole: user.role,
            currentUserID: user.id,
            visualizationOwnerID: visualizationOwnerID
        )
    }
    // MARK: - Private Properties
    
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
    /// Creates a `ThreadScreenViewModel` with all required dependencies injected.
    ///
    /// - Parameters:
    ///   - visualizationID: The Firestore ID of the visualization whose threads are displayed.
    ///   - visualizationOwnerID: The user ID of the visualization's author, used for permission checks.
    ///   - isPreview: When `true`, skips all network calls. Used for SwiftUI previews.
    ///   - repository: Provides comment and reply CRUD operations.
    ///   - userRepository: Resolves user profiles by ID.
    ///   - authRepository: Retrieves the current authenticated user's ID.
    ///   - postCommentUseCase: Handles posting a new text or snip thread.
    ///   - postReplyUseCase: Handles posting a reply to an existing thread.
    ///   - deleteCommentUseCase: Handles deleting a comment after permission validation.
    ///   - deleteReplyUseCase: Handles deleting a reply after permission validation.
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
    // MARK: - Debug Preview

    #if DEBUG
    /// Returns a pre-populated `ThreadScreenViewModel` for use in SwiftUI previews.
    /// Network calls are disabled via `isPreview: true`.
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
    
    // MARK: - User

    /// Fetches the authenticated user from `AuthRepository` and `UserRepository`,
    /// and assigns the result to `currentUser`.
    /// Must be called before any write operation, as use cases require a valid user.
    func fetchCurrentUser() async {
        guard !isPreview else { return }
        do {
            let userID = try await authRepository.getCurrentUserID()
            currentUser = try await userRepository.getUserByID(userID: userID)
        } catch {
            self.error = error.localizedDescription
        }
    }
    // MARK: - Load
    
    /// Fetches all comments and their nested replies for the current visualization.
    /// Replaces the entire `comments` array with the freshly loaded data.
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
    // MARK: - Post
    
    /// Posts a new text thread and appends only the newly created comment
    /// to the existing list, avoiding a full reload.
    ///
    /// - Parameter content: The text content of the new thread.
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
    
    /// Posts a reply under an existing thread and refreshes only the affected
    /// comment in the list, avoiding a full reload.
    ///
    /// - Parameters:
    ///   - commentID: The ID of the comment to reply to.
    ///   - content: The text content of the reply.
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
    // MARK: - Delete
    
    /// Deletes a comment after verifying the requesting user has permission.
    /// Removes the comment from the local array immediately on success.
    ///
    /// - Parameters:
    ///   - commentID: The ID of the comment to delete.
    ///   - authorID: The ID of the comment's author, used for permission validation.
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
    
    /// Deletes a reply after verifying the requesting user has permission.
    /// Removes the reply from its parent comment's thread list immediately on success.
    ///
    /// - Parameters:
    ///   - commentID: The ID of the parent comment.
    ///   - replyID: The ID of the reply to delete.
    ///   - authorID: The ID of the reply's author, used for permission validation.
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
    
    // MARK: - Partial Updates
    
    /// Fetches all comments and appends only those not already present in the list.
    /// Used after posting a new comment or snip to avoid a full reload.
    /// Also called externally by `FullScreen` after a snip is successfully uploaded.
    func appendNewComments() async {
        do {
            let all = try await repository.loadComments(visualizationID: visualizationID)
            let existingIDs = Set(comments.map { $0.id })
            let newComments = all.filter { !existingIDs.contains($0.id) }
            comments.append(contentsOf: newComments)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    /// Fetches all comments and updates only the comment matching `commentID`.
    /// Used after posting a reply to refresh the affected thread without a full reload.
    ///
    /// - Parameter commentID: The ID of the comment to refresh.
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
