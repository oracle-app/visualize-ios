//
//  CommentUseCaseTests.swift
//  visualizeTests
//
//  Created by Kimberly Marquez on 07/06/26.
//
//  Test cases: COMM-001 to COMM-008 — Domain Layer
//  Module: Comments and Threads
//  Test Plan v1.0 — June 2026
//
///  These tests execute Domain Use Cases directly to maximize isolation and granularity,
///  bypassing the presentation layer (ViewModel). Shared mock implementations reside in
///  MockCommentRepositories.swift.
///
///  This suite complements ThreadScreenViewModelTests.swift, which covers identical
///  functional requirements at the presentation and state management level.
//

import XCTest
@testable import visualize

/// Domain-layer test suite validating business rules for comments and nested conversation threads.
final class CommentUseCaseTests: XCTestCase {

    // MARK: - Shared Test Context

    /// Fixed identifier targeting a mock visualization asset.
    let visualizationID = "viz1"
    
    /// Target identifier for mock top-level comment structures.
    let commentID       = "c1"
    
    /// Target identifier for mock nested sub-thread reply structures.
    let replyID         = "r1"

    /// Shared session profile acting as the primary actor for authorized interactions.
    let author = AppUser(
        id: "u1",
        email: "test@test.com",
        profilePictureURL: nil,
        username: "testuser",
        role: .admin
    )

    // MARK: - COMM-001: Post Text Comment Successfully
    
    /// **COMM-001: Functional | Priority: High**
    ///
    /// Verifies that passing a non-empty text payload successfully routes the payload details
    /// down to the underlying data architecture via the repository interface.
    ///
    /// * Expected Outcome: `postComment` is invoked on the repository with correct text components.
    func test_COMM001_postCommentUseCase_validContent_callsRepository() async throws {
        // Arrange
        let repo = MockThreadCommentRepository()
        let useCase = PostCommentUseCase(repository: repo)

        // Act
        try await useCase.execute(
            visualizationID: visualizationID,
            author: author,
            content: "Hola mundo",
            imageURL: nil
        )

        // Assert
        XCTAssertTrue(repo.postCommentCalled, "The repository must receive the postComment command invocation.")
        XCTAssertEqual(repo.lastPostedContent, "Hola mundo", "The payload content forwarded to the repository must match the input.")
        XCTAssertNil(repo.postCommentError, "No operations should fail when supplied with standard text content.")
    }

    // MARK: - COMM-002: Reject Empty Text Comment
    
    /// **COMM-002: Validation | Priority: High**
    ///
    /// Validates that domain rules intercept whitespace-only payloads and abort processing
    /// before executing network operations.
    ///
    /// * Expected Outcome: Throws `CommentError.emptyContent`; repository interaction is completely blocked.
    func test_COMM002_postCommentUseCase_emptyContent_throwsEmptyContent() async {
        // Arrange
        let repo = MockThreadCommentRepository()
        let useCase = PostCommentUseCase(repository: repo)

        // Act & Assert
        do {
            try await useCase.execute(
                visualizationID: visualizationID,
                author: author,
                content: "   ",
                imageURL: nil
            )
            XCTFail("Domain boundary should have rejected whitespace-only strings by throwing CommentError.emptyContent.")
        } catch CommentError.emptyContent {
            // Expected failure caught successfully
        } catch {
            XCTFail("Caught unexpected error signature: \(error)")
        }

        XCTAssertFalse(repo.postCommentCalled, "Repository must never be triggered when input criteria fail validation.")
    }

    // MARK: - COMM-003: Post Nested Reply Successfully
    
    /// **COMM-003: Functional | Priority: High**
    ///
    /// Confirms that dispatching a valid reply payload attaches correctly to a specific target thread parent.
    ///
    /// * Expected Outcome: `postReply` is called with matching parameters on the transaction repository.
    func test_COMM003_postReplyUseCase_validContent_callsRepository() async throws {
        // Arrange
        let repo = MockThreadCommentRepository()
        let useCase = PostReplyUseCase(repository: repo)

        // Act
        try await useCase.execute(
            visualizationID: visualizationID,
            commentID: commentID,
            author: author,
            content: "Mi reply"
        )

        // Assert
        XCTAssertTrue(repo.postReplyCalled, "The repository must register a postReply interaction.")
        XCTAssertEqual(repo.lastPostedReplyContent, "Mi reply", "The forwarded reply body text must align with the input source data.")
    }

    // MARK: - COMM-004: Reject Empty Thread Reply
    
    /// **COMM-004: Validation | Priority: Medium**
    ///
    /// Assures nested sub-threads enforce identical validation guarantees as root comments against blank inputs.
    ///
    /// * Expected Outcome: Throws `CommentError.emptyContent`; execution is terminated early.
    func test_COMM004_postReplyUseCase_emptyContent_throwsEmptyContent() async {
        // Arrange
        let repo = MockThreadCommentRepository()
        let useCase = PostReplyUseCase(repository: repo)

        // Act & Assert
        do {
            try await useCase.execute(
                visualizationID: visualizationID,
                commentID: commentID,
                author: author,
                content: ""
            )
            XCTFail("Domain boundaries must reject blank sub-thread messages by raising CommentError.emptyContent.")
        } catch CommentError.emptyContent {
            // Expected validation failure caught
        } catch {
            XCTFail("Caught incorrect error signature: \(error)")
        }

        XCTAssertFalse(repo.postReplyCalled, "The network repository layer should not be contacted for empty replies.")
    }

    // MARK: - COMM-005: Delete Personally Authored Comment
    
    /// **COMM-005: Functional | Priority: High**
    ///
    /// Evaluates that valid ownership credentials grant complete access to purge a commentary resource.
    ///
    /// * Expected Outcome: `deleteComment` passes ownership checks, maps down to repository, and purges state.
    func test_COMM005_deleteCommentUseCase_ownComment_callsRepository() async throws {
        // Arrange
        let repo = MockThreadCommentRepository()
        repo.stubbedComments = [
            Comment(
                id: commentID,
                authorID: author.id,   // Matching identifier establishes ownership
                authorName: author.username,
                content: "Mi comentario",
                imageURL: nil,
                createdAt: Date(),
                threads: []
            )
        ]
        let useCase = DeleteCommentUseCase(repository: repo)

        // Act
        try await useCase.execute(
            visualizationID: visualizationID,
            commentID: commentID,
            requestingUserID: author.id,
            authorID: author.id
        )

        // Assert
        XCTAssertTrue(repo.deleteCommentCalled, "The repository must execute the backing deleteComment method.")
        XCTAssertEqual(repo.lastDeletedCommentID, commentID, "The repository must target the precise resource identity specified.")
        XCTAssertTrue(repo.stubbedComments.isEmpty, "The internal memory cache should immediately reflect database drop completions.")
    }

    // MARK: - COMM-006: Deny Purging Foreign Comments
    
    /// **COMM-006: Security | Priority: High**
    ///
    /// Validates safety structures preventing standard accounts from tampering with or deleting content
    /// owned by external profiles.
    ///
    /// * Expected Outcome: Throws `CommentError.unauthorized`; repository changes are skipped entirely.
    func test_COMM006_deleteCommentUseCase_foreignComment_throwsUnauthorized() async {
        // Arrange
        let repo = MockThreadCommentRepository()
        repo.stubbedComments = [
            Comment(
                id: "c2",
                authorID: "u99",   // External user identity
                authorName: "Otro Usuario",
                content: "Comentario ajeno",
                imageURL: nil,
                createdAt: Date(),
                threads: []
            )
        ]
        let useCase = DeleteCommentUseCase(repository: repo)

        // Act & Assert
        do {
            try await useCase.execute(
                visualizationID: visualizationID,
                commentID: "c2",
                requestingUserID: author.id,   // Identity u1 attempting unauthorized write on u99 asset
                authorID: "u99"
            )
            XCTFail("Security context must intercept unauthorized mutations by raising CommentError.unauthorized.")
        } catch CommentError.unauthorized {
            // Expected security interception caught
        } catch {
            XCTFail("Encountered unexpected non-security error domain: \(error)")
        }

        XCTAssertFalse(repo.deleteCommentCalled, "Repository transaction layer must reject unauthorized write commands.")
        XCTAssertEqual(repo.stubbedComments.count, 1, "The target resource state must remain unmutated inside the dataset.")
    }

    // MARK: - COMM-007: Delete Personally Authored Reply
    
    /// **COMM-007: Functional | Priority: Medium**
    ///
    /// Assures that individual users possess operational control to remove sub-thread items they created.
    ///
    /// * Expected Outcome: `deleteReply` maps to repository, isolating and extracting the targeted sub-element.
    func test_COMM007_deleteReplyUseCase_ownReply_callsRepository() async throws {
        // Arrange
        let repo = MockThreadCommentRepository()
        repo.stubbedComments = [
            Comment(
                id: commentID,
                authorID: "u2",
                authorName: "Otro",
                content: "Comentario padre",
                imageURL: nil,
                createdAt: Date(),
                threads: [
                    ThreadReply(
                        id: replyID,
                        authorID: author.id,   // Matching identifier establishes nested resource ownership
                        authorName: author.username,
                        authorAvatarURL: nil,
                        createdAt: Date(),
                        content: "Mi reply"
                    )
                ]
            )
        ]
        let useCase = DeleteReplyUseCase(repository: repo)

        // Act
        try await useCase.execute(
            visualizationID: visualizationID,
            commentID: commentID,
            replyID: replyID,
            requestingUserID: author.id,
            authorID: author.id
        )

        // Assert
        XCTAssertTrue(repo.deleteReplyCalled, "The repository transaction framework must receive a clear deleteReply instruction.")
        XCTAssertEqual(repo.lastDeletedReplyID, replyID, "The deletion instruction must match the targeted nested element identifier.")
        XCTAssertTrue(
            repo.stubbedComments.first?.threads.isEmpty ?? false,
            "The specific target sub-element must be extracted cleanly out of its parent conversation thread container."
        )
    }

    // MARK: - COMM-008: Deny Purging Foreign Replies
    
    /// **COMM-008: Security | Priority: High**
    ///
    /// Confirms that nested messaging structures remain safe against cross-profile permission bypass exploits.
    ///
    /// * Expected Outcome: Throws `CommentError.unauthorized`; underlying structural layout stays protected.
    func test_COMM008_deleteReplyUseCase_foreignReply_throwsUnauthorized() async {
        // Arrange
        let repo = MockThreadCommentRepository()
        repo.stubbedComments = [
            Comment(
                id: commentID,
                authorID: "u2",
                authorName: "Otro",
                content: "Comentario padre",
                imageURL: nil,
                createdAt: Date(),
                threads: [
                    ThreadReply(
                        id: "r2",
                        authorID: "u99",   // External user resource owner
                        authorName: "Otro Usuario",
                        authorAvatarURL: nil,
                        createdAt: Date(),
                        content: "Reply ajena"
                    )
                ]
            )
        ]
        let useCase = DeleteReplyUseCase(repository: repo)

        // Act & Assert
        do {
            try await useCase.execute(
                visualizationID: visualizationID,
                commentID: commentID,
                replyID: "r2",
                requestingUserID: author.id,   // Actor u1 attempting unauthorized drop execution on u99 resource
                authorID: "u99"
            )
            XCTFail("Security context must interrupt unauthorized nested mutation tasks by throwing CommentError.unauthorized.")
        } catch CommentError.unauthorized {
            // Expected protection mechanism verified
        } catch {
            XCTFail("Encountered unexpected fallback error type: \(error)")
        }

        XCTAssertFalse(repo.deleteReplyCalled, "The physical repository access layers must discard foreign structural updates.")
        XCTAssertEqual(
            repo.stubbedComments.first?.threads.count, 1,
            "The targeted nested thread data object must be preserved intact inside the source collection model."
        )
    }
}
