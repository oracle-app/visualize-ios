//
//  ThreadScreenViewModelTests.swift
//  visualizeTests
//
//  Created by Kimberly Marquez on 07/06/26.
//
///  Test cases: COMM-001 to COMM-008 — Presentation Layer
///  Module: Comments and Threads
///  Test Plan v1.0 — June 2026
///
///  These tests verify that the ViewModel correctly maps actions to internal UI state changes
///  (e.g., mutating `vm.comments`, exposing descriptive errors via `vm.error`, or driving `vm.isLoading`).
///  Pure isolated business logic validation is decoupled and covered separately within CommentUseCaseTests.swift.
///
///  Shared mock implementations reside inside MockCommentRepositories.swift,
///  following the project architecture conventions defined in Libia's MockAuthRepositories.swift.
//

import XCTest
@testable import visualize

/// Presentation-layer test suite verifying structural state machines, error exposure,
/// and reactive collection updates on the `ThreadScreenViewModel`.
@MainActor
final class ThreadScreenViewModelTests: XCTestCase {

    // MARK: - Shared Test Context

    /// Standard local user profile utilized to simulate active UI dashboard sessions.
    let currentUser = AppUser(
        id: "u1",
        email: "test@test.com",
        profilePictureURL: nil,
        username: "testuser",
        role: .admin
    )

    // MARK: - COMM-001: Post Text Comment UI Pipeline
    
    /// **COMM-001: Functional | Priority: High**
    ///
    /// Validates that an authorized user successfully dispatching a text comment triggers
    /// an immediate list refresh and flushes any prior transient error state out of the viewport.
    ///
    /// * ViewModel Concern: `vm.comments` updates reactivity with new nodes; `vm.error` resets to `nil`.
    func test_COMM001_postComment_success_updatesUIState() async throws {
        // Arrange
        let commentRepo = MockThreadCommentRepository()
        commentRepo.stubbedComments = [
            Comment(
                id: "c1",
                authorID: "u1",
                authorName: "testuser",
                content: "Hola mundo",
                imageURL: nil,
                createdAt: Date(),
                threads: []
            )
        ]
        let vm = makeCommentTestViewModel(commentRepo: commentRepo, currentUser: currentUser)

        // Act
        await vm.postComment(content: "Hola mundo")

        // Assert — UI state
        XCTAssertNil(vm.error, "ViewModel internal error reference must be nil following a successful text post completion.")
        XCTAssertFalse(vm.comments.isEmpty, "ViewModel published collection must append and display the newly created comment object.")
    }

    // MARK: - COMM-002: Handle Empty Comment UI Validation
    
    /// **COMM-002: Validation | Priority: High**
    ///
    /// Assures that if input filters flag an empty or invalid character sequence, the UI state engine intercepts
    /// the fallback, populates error variables for localization presentation, and prevents broken view re-renders.
    ///
    /// * ViewModel Concern: `vm.error` is exposed to drive alerts; `vm.comments` remains unmodified.
    func test_COMM002_postComment_emptyContent_exposesErrorAndKeepsListEmpty() async throws {
        // Arrange
        let commentRepo = MockThreadCommentRepository()
        let vm = makeCommentTestViewModel(commentRepo: commentRepo, currentUser: currentUser)

        // Act
        await vm.postComment(content: "   ")

        // Assert — UI state
        XCTAssertNotNil(vm.error, "ViewModel must explicitly publish a descriptive UI state error when intercepting whitespace payloads.")
        XCTAssertTrue(vm.comments.isEmpty, "The binding target comments collection state must remain entirely unchanged.")
    }

    // MARK: - COMM-003: Cascade Nested Replies into View Tree
    
    /// **COMM-003: Functional | Priority: High**
    ///
    /// Validates that adding a sub-thread reply to an active comment node inserts the model object directly
    /// within the nested tree structure bound to the interface layout.
    ///
    /// * ViewModel Concern: Target reply item appends into the parent thread container within `vm.comments`.
    func test_COMM003_postReply_success_nestedUnderParentInUI() async throws {
        // Arrange
        let commentRepo = MockThreadCommentRepository()
        commentRepo.stubbedComments = [
            Comment(
                id: "c1",
                authorID: "u2",
                authorName: "Otro Usuario",
                content: "Comentario padre",
                imageURL: nil,
                createdAt: Date(),
                threads: [
                    ThreadReply(
                        id: "r1",
                        authorID: "u1",
                        authorName: "testuser",
                        authorAvatarURL: nil,
                        createdAt: Date(),
                        content: "Mi reply"
                    )
                ]
            )
        ]
        let vm = makeCommentTestViewModel(commentRepo: commentRepo, currentUser: currentUser)
        await vm.loadComments()

        // Act
        await vm.postReply(to: "c1", content: "Mi reply")

        // Assert — UI state
        XCTAssertNil(vm.error, "Active error flags must remain nil upon successful insertion of a sub-thread message.")
        let replies = vm.comments.first(where: { $0.id == "c1" })?.threads
        XCTAssertEqual(replies?.count, 1, "The nested thread replies array must cleanly reflect the appended message in the UI dataset.")
        XCTAssertEqual(replies?.first?.content, "Mi reply", "The visible nested message string properties must correspond to user input values.")
    }

    // MARK: - COMM-004: Handle Empty Reply UI Validation
    
    /// **COMM-004: Validation | Priority: Medium**
    ///
    /// Confirms that empty sub-thread payloads trigger diagnostic state responses to alert the user interface.
    ///
    /// * ViewModel Concern: `vm.error` captures validation payload; nested target tree blocks manipulation.
    func test_COMM004_postReply_emptyContent_exposesError() async throws {
        // Arrange
        let commentRepo = MockThreadCommentRepository()
        let vm = makeCommentTestViewModel(commentRepo: commentRepo, currentUser: currentUser)

        // Act
        await vm.postReply(to: "c1", content: "")

        // Assert — UI state
        XCTAssertNotNil(vm.error, "ViewModel must populate error bindings if an empty sub-thread string is evaluated.")
    }

    // MARK: - COMM-005: Purge Owned Comment From UI State
    
    /// **COMM-005: Functional | Priority: High**
    ///
    /// Confirms that when a user purges their own comment node, the item is removed from the visible list
    /// and the UI cleans up smoothly.
    ///
    /// * ViewModel Concern: Node is dropped from `vm.comments`; any active error remains clear.
    func test_COMM005_deleteComment_ownComment_removedFromUIList() async throws {
        // Arrange
        let commentRepo = MockThreadCommentRepository()
        commentRepo.stubbedComments = [
            Comment(
                id: "c1",
                authorID: "u1", // Explicit ownership mapping to currentUser
                authorName: "testuser",
                content: "Mi comentario",
                imageURL: nil,
                createdAt: Date(),
                threads: []
            )
        ]
        let vm = makeCommentTestViewModel(commentRepo: commentRepo, currentUser: currentUser)
        await vm.loadComments()
        XCTAssertEqual(vm.comments.count, 1, "Pre-condition setup validation: Visual data collection must initially contain exactly 1 comment node.")

        // Act
        await vm.deleteComment(commentID: "c1", authorID: "u1")

        // Assert — UI state
        XCTAssertNil(vm.error, "ViewModel error status must remain clear when executing valid self-authored resource drops.")
        XCTAssertTrue(vm.comments.isEmpty, "The deleted comment must be systematically scrubbed out of the displayed ui collection.")
    }

    // MARK: - COMM-006: Capture UI Errors on Unauthorized Comment Deletion
    
    /// **COMM-006: Security | Priority: High**
    ///
    /// Assures that when trying to delete someone else's comment, the application surface catches the exception,
    /// blocks it, and reports an authorization error to the user interface.
    ///
    /// * ViewModel Concern: `vm.error` presents rejection message; list remains intact.
    func test_COMM006_deleteComment_foreignComment_exposesErrorAndKeepsList() async throws {
        // Arrange
        let commentRepo = MockThreadCommentRepository()
        commentRepo.stubbedComments = [
            Comment(
                id: "c2",
                authorID: "u99", // Belongs to an external user account context
                authorName: "Otro Usuario",
                content: "Comentario ajeno",
                imageURL: nil,
                createdAt: Date(),
                threads: []
            )
        ]
        let vm = makeCommentTestViewModel(commentRepo: commentRepo, currentUser: currentUser)
        await vm.loadComments()

        // Act
        await vm.deleteComment(commentID: "c2", authorID: "u99")

        // Assert — UI state
        XCTAssertNotNil(vm.error, "ViewModel must surface an unauthorized rejection code or enum state to protect third-party assets.")
        XCTAssertEqual(vm.comments.count, 1, "The user display collection structure must retain the untouched foreign node elements.")
    }

    // MARK: - COMM-007: Purge Owned Reply From UI Tree Structure
    
    /// **COMM-007: Functional | Priority: Medium**
    ///
    /// Assures that if a user deletes a sub-thread reply they created, the internal structure isolates
    /// the exact item and removes it from the parent conversation thread in the UI.
    ///
    /// * ViewModel Concern: Nested sub-reply disappears dynamically from `vm.comments` node tree.
    func test_COMM007_deleteReply_ownReply_removedFromParentInUI() async throws {
        // Arrange
        let commentRepo = MockThreadCommentRepository()
        commentRepo.stubbedComments = [
            Comment(
                id: "c1",
                authorID: "u2",
                authorName: "Otro",
                content: "Padre",
                imageURL: nil,
                createdAt: Date(),
                threads: [
                    ThreadReply(
                        id: "r1",
                        authorID: "u1", // Explicit ownership mapping to currentUser
                        authorName: "testuser",
                        authorAvatarURL: nil,
                        createdAt: Date(),
                        content: "Mi reply"
                    )
                ]
            )
        ]
        let vm = makeCommentTestViewModel(commentRepo: commentRepo, currentUser: currentUser)
        await vm.loadComments()
        XCTAssertEqual(vm.comments.first?.threads.count, 1, "Pre-condition verification: Target parent node must initialize with exactly 1 sub-thread reply visual instance.")

        // Act
        await vm.deleteReply(commentID: "c1", replyID: "r1", authorID: "u1")

        // Assert — UI state
        XCTAssertNil(vm.error, "ViewModel error variables must remain null following an authorized self-reply drop execution.")
        XCTAssertTrue(
            vm.comments.first?.threads.isEmpty ?? false,
            "The selected child item must be safely filtered out of the visual display branch collection mapping."
        )
    }

    // MARK: - COMM-008: Capture UI Errors on Unauthorized Reply Deletion
    
    /// **COMM-008: Security | Priority: High**
    ///
    /// Evaluates that attempting to remove a third-party sub-thread reply updates the active state error reference
    /// and leaves the current layout completely unaffected.
    ///
    /// * ViewModel Concern: `vm.error` captures security violation; layout elements are preserved.
    func test_COMM008_deleteReply_foreignReply_exposesErrorAndKeepsThreads() async throws {
        // Arrange
        let commentRepo = MockThreadCommentRepository()
        commentRepo.stubbedComments = [
            Comment(
                id: "c1",
                authorID: "u2",
                authorName: "Otro",
                content: "Padre",
                imageURL: nil,
                createdAt: Date(),
                threads: [
                    ThreadReply(
                        id: "r2",
                        authorID: "u99", // Belongs to an external user account context
                        authorName: "Otro Usuario",
                        authorAvatarURL: nil,
                        createdAt: Date(),
                        content: "Reply ajena"
                    )
                ]
            )
        ]
        let vm = makeCommentTestViewModel(commentRepo: commentRepo, currentUser: currentUser)
        await vm.loadComments()

        // Act
        await vm.deleteReply(commentID: "c1", replyID: "r2", authorID: "u99")

        // Assert — UI state
        XCTAssertNotNil(vm.error, "ViewModel state machine must flag and present a security violation exception when dropping third-party replies.")
        XCTAssertEqual(
            vm.comments.first?.threads.count, 1,
            "The targeted nested thread data collection must ignore unauthorized changes to remain structurally integrated."
        )
    }
}
