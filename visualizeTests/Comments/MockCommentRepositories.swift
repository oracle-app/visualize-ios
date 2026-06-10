//
//  MockCommentRepositories.swift
//  visualizeTests
//
//  Created by Kimberly Marquez on 07/06/26.
//
///  Shared mock stubs for comment/thread unit tests (COMM-001 → COMM-008).
///  Follows the same convention as Libia's MockAuthRepositories.swift.
///  Import this file into your test target — all COMM files depend on these mocks.
//

import XCTest
@testable import visualize

// MARK: - MockThreadCommentRepository

/// A highly configurable mock implementation of `CommentRepository`.
///
/// This class simulates all CRUD operations for comments and threads entirely in-memory,
/// eliminating any dependencies on Firebase or network connectivity during unit tests.
///
/// Since production Use Cases are declared as `final class` and cannot be subclassed,
/// this mock is injected directly via protocol conformance to achieve dependency inversion.
///
/// ### Usage Example:
/// ```swift
/// let mockRepo = MockThreadCommentRepository()
/// mockRepo.stubbedComments = [Comment(id: "c1", content: "Hello")]
/// // Force an error if needed:
/// mockRepo.loadError = NSError(domain: "Test", code: 404)
/// ```
final class MockThreadCommentRepository: CommentRepository {

    // MARK: Load Configuration
    
    /// If populated, `loadComments(visualizationID:)` will immediately throw this error.
    var loadError: Error?
    
    /// In-memory array used to stub successful comment lookups.
    var stubbedComments: [Comment] = []

    /// Simulates fetching comments for a specific visualization.
    /// - Parameter visualizationID: The unique identifier of the visualization.
    /// - Returns: An array of stubbed `Comment` models.
    /// - Throws: An `Error` if `loadError` is explicitly set.
    func loadComments(visualizationID: String) async throws -> [Comment] {
        if let error = loadError { throw error }
        return stubbedComments
    }

    // MARK: Post Comment Configuration
    
    /// If populated, `postComment` will immediately throw this error.
    var postCommentError: Error?
    
    /// A spy flag indicating whether `postComment` was called during the test execution.
    var postCommentCalled = false
    
    /// Captures the raw text string passed to the last `postComment` invocation.
    var lastPostedContent: String?

    /// Simulates publishing a top-level comment.
    /// - Parameters:
    ///   - visualizationID: Target visualization identifier.
    ///   - author: The `AppUser` model representing the author.
    ///   - content: The text body of the comment.
    ///   - imageURL: Optional attachment URL.
    /// - Throws: An `Error` if `postCommentError` is set.
    func postComment(
        visualizationID: String,
        author: AppUser,
        content: String,
        imageURL: String?
    ) async throws {
        postCommentCalled = true
        lastPostedContent = content
        if let error = postCommentError { throw error }
    }

    // MARK: Delete Comment Configuration
    
    /// If populated, `deleteComment` will immediately throw this error.
    var deleteCommentError: Error?
    
    /// A spy flag indicating whether `deleteComment` was called.
    var deleteCommentCalled = false
    
    /// Captures the specific comment ID targeted for deletion during the last invocation.
    var lastDeletedCommentID: String?

    /// Simulates removing a top-level comment and mutates the local `stubbedComments` state.
    /// - Parameters:
    ///   - visualizationID: Target visualization identifier.
    ///   - commentID: Unique identifier of the comment to remove.
    /// - Throws: An `Error` if `deleteCommentError` is set.
    func deleteComment(visualizationID: String, commentID: String) async throws {
        deleteCommentCalled = true
        lastDeletedCommentID = commentID
        if let error = deleteCommentError { throw error }
        stubbedComments.removeAll { $0.id == commentID }
    }

    // MARK: Post Reply Configuration
    
    /// If populated, `postReply` will immediately throw this error.
    var postReplyError: Error?
    
    /// A spy flag indicating whether `postReply` was called.
    var postReplyCalled = false
    
    /// Captures the raw text string passed to the last `postReply` invocation.
    var lastPostedReplyContent: String?

    /// Simulates publishing a nested reply inside an existing comment thread.
    /// - Parameters:
    ///   - visualizationID: Target visualization identifier.
    ///   - commentID: Parent comment identifier.
    ///   - author: The `AppUser` model replying to the thread.
    ///   - content: The text body of the reply.
    /// - Throws: An `Error` if `postReplyError` is set.
    func postReply(
        visualizationID: String,
        commentID: String,
        author: AppUser,
        content: String
    ) async throws {
        postReplyCalled = true
        lastPostedReplyContent = content
        if let error = postReplyError { throw error }
    }

    // MARK: Delete Reply Configuration
    
    /// If populated, `deleteReply` will immediately throw this error.
    var deleteReplyError: Error?
    
    /// A spy flag indicating whether `deleteReply` was called.
    var deleteReplyCalled = false
    
    /// Captures the specific reply ID targeted for deletion during the last invocation.
    var lastDeletedReplyID: String?

    /// Simulates removing a reply and updates the nested sub-thread structure inside `stubbedComments`.
    /// - Parameters:
    ///   - visualizationID: Target visualization identifier.
    ///   - commentID: Parent comment identifier containing the target reply thread.
    ///   - replyID: Unique identifier of the reply to remove.
    /// - Throws: An `Error` if `deleteReplyError` is set.
    func deleteReply(
        visualizationID: String,
        commentID: String,
        replyID: String
    ) async throws {
        deleteReplyCalled = true
        lastDeletedReplyID = replyID
        if let error = deleteReplyError { throw error }
        if let index = stubbedComments.firstIndex(where: { $0.id == commentID }) {
            stubbedComments[index].threads.removeAll { $0.id == replyID }
        }
    }

    // MARK: Snip Configuration
    
    /// A spy flag indicating whether `postSnipComment` was called.
    var postSnipCommentCalled = false

    /// Simulates adding a specialized "snip" content comment context.
    func postSnipComment(
        visualizationID: String,
        authorID: String,
        imageURL: URL,
        authorName: String,
        caption: String?
    ) async throws {
        postSnipCommentCalled = true
    }
}

// MARK: - MockUserRepositoryComment

/// A scoped mock of `UserRepository` tailored strictly for user data resolution within comment tests.
///
/// Unrelated user management operations are intentionally stubbed with a `fatalError` invocation
/// to establish strict guardrails against unexpected side effects during `COMM` test flows.
final class MockUserRepositoryComment: UserRepository {

    /// Pre-configured app user instance representing the standard mock author session.
    var stubbedUser: AppUser = AppUser(
        id: "u1",
        email: "test@test.com",
        profilePictureURL: nil,
        username: "testuser",
        role: .admin
    )

    /// Always resolves immediately with the internal `stubbedUser` instance.
    func getUserByID(userID: String) async throws -> AppUser { stubbedUser }
    
    /// - Warning: Triggers `fatalError`. Unused in COMM flows.
    func createUser(user: AppUser) async throws -> AppUser { fatalError("Not needed in COMM tests") }
    
    /// Returns an empty array immediately.
    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] { [] }
    
    /// No-op operation for comment workflow isolation.
    func addHiddenVisualization(userID: String, visualizationID: String) async throws {}
    
    /// No-op operation for comment workflow isolation.
    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {}
    
    /// No-op operation for comment workflow isolation.
    func updateProfilePictureURL(userID: String, url: URL?) async throws {}
    
    /// - Warning: Triggers `fatalError`. Unused in COMM flows.
    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL {
        fatalError("Not needed in COMM tests")
    }
    
    /// No-op operation for comment workflow isolation.
    func deleteProfileImage(byURL url: URL) async throws {}
}

// MARK: - MockAuthRepositoryComment

/// A minimal mock of `AuthRepository` scoped strictly to providing current user metadata.
///
/// For testing complex authentication states, registration, or session handling,
/// refer directly to Libia's centralized `MockAuthRepositories.swift`.
final class MockAuthRepositoryComment: AuthRepository {

    /// Pre-configured user ID acting as the current session placeholder.
    var stubbedUserID: String = "u1"

    /// Resolves immediately to the configured `stubbedUserID`.
    func getCurrentUserID() async throws -> String { stubbedUserID }
    
    /// Always returns `nil` since detailed auth tokens are not verified in `COMM` tests.
    func getCurrentUser() -> AuthUser? { nil }
    
    /// - Warning: Triggers `fatalError`. Refer to `MockAuthRepositories.swift` instead.
    func login(email: String, password: String) async throws -> AuthUser {
        fatalError("Not needed in COMM tests — see MockAuthRepositories.swift")
    }
    
    /// - Warning: Triggers `fatalError`. Refer to `MockAuthRepositories.swift` instead.
    func register(email: String, password: String) async throws -> AuthUser {
        fatalError("Not needed in COMM tests — see MockAuthRepositories.swift")
    }
    
    /// - Warning: Triggers `fatalError`. Refer to `MockAuthRepositories.swift` instead.
    func logout() throws {
        fatalError("Not needed in COMM tests — see MockAuthRepositories.swift")
    }
    
    /// No-op operation for comment workflow isolation.
    func deleteCurrentUser() async throws {}
    
    /// - Warning: Triggers `fatalError`. Refer to `MockAuthRepositories.swift` instead.
    func sendPasswordReset(to email: String) async throws {
        fatalError("Not needed in COMM tests — see MockAuthRepositories.swift")
    }
}

// MARK: - Factory Helper

/// Centralized test factory designed to instantiate a fully configured `ThreadScreenViewModel`.
///
/// This helper abstracts the dependency graph generation (injecting the mock repository into
/// both the view model and its final Use Cases), reducing boilerplate across all `COMM` test suites.
///
/// - Parameters:
///   - commentRepo: A custom-configured instance of `MockThreadCommentRepository`. Defaults to a new instance.
///   - currentUser: The app user acting as the session owner. Defaults to an admin profile (`id: "u1"`).
/// - Returns: A fully initialized `ThreadScreenViewModel` ready for unit testing.
@MainActor
func makeCommentTestViewModel(
    commentRepo: MockThreadCommentRepository = MockThreadCommentRepository(),
    currentUser: AppUser = AppUser(
        id: "u1",
        email: "test@test.com",
        profilePictureURL: nil,
        username: "testuser",
        role: .admin
    )
) -> ThreadScreenViewModel {
    let vm = ThreadScreenViewModel(
        visualizationID: "viz1",
        visualizationOwnerID: "u1",
        isPreview: false,
        repository: commentRepo,
        userRepository: MockUserRepositoryComment(),
        authRepository: MockAuthRepositoryComment(),
        postCommentUseCase: PostCommentUseCase(repository: commentRepo),
        postReplyUseCase: PostReplyUseCase(repository: commentRepo),
        deleteCommentUseCase: DeleteCommentUseCase(repository: commentRepo),
        deleteReplyUseCase: DeleteReplyUseCase(repository: commentRepo)
    )
    vm.currentUser = currentUser
    return vm
}
