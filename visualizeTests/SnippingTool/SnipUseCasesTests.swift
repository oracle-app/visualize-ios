//
//  SnipUseCasesTests.swift
//  visualizeTests
//
//  Unit tests for the Snipping Tool publishing flow:
//  - UploadSnipUseCase  (PNG encoding + Storage path + upload)
//  - PostSnipCommentUseCase  (Firestore comment write)
//
//  Test plan coverage:
//  - SNIP-002: Capture and upload snip successfully
//  - SNIP-003: Image conversion to PNG fails -> SnipUploadError.imageConversionFailed
//  Plus: storage path format, repository error propagation.
//

import XCTest
import UIKit
@testable import visualize

// MARK: - Mocks

private final class SnippingToolTestsMockSnipRepository: SnipRepository {
    var uploadCallCount = 0
    var receivedData: Data?
    var receivedPath: String?
    var stubbedURL = URL(string: "https://storage.example.com/snip.png")!
    var stubbedError: Error?

    func uploadSnip(data: Data, path: String) async throws -> URL {
        uploadCallCount += 1
        receivedData = data
        receivedPath = path
        if let error = stubbedError { throw error }
        return stubbedURL
    }
}

private final class SnippingToolTestsMockCommentRepository: CommentRepository {
    var postSnipCallCount = 0
    var receivedVisualizationID: String?
    var receivedAuthorID: String?
    var receivedImageURL: URL?
    var receivedAuthorName: String?
    var receivedCaption: String?
    var stubbedError: Error?

    func postSnipComment(visualizationID: String, authorID: String, imageURL: URL, authorName: String, caption: String?) async throws {
        postSnipCallCount += 1
        receivedVisualizationID = visualizationID
        receivedAuthorID = authorID
        receivedImageURL = imageURL
        receivedAuthorName = authorName
        receivedCaption = caption
        if let error = stubbedError { throw error }
    }

    // Unused in these tests — stubbed to satisfy the protocol.
    func loadComments(visualizationID: String) async throws -> [Comment] { [] }
    func postComment(visualizationID: String, author: AppUser, content: String, imageURL: String?) async throws {}
    func deleteComment(visualizationID: String, commentID: String) async throws {}
    func postReply(visualizationID: String, commentID: String, author: AppUser, content: String) async throws {}
    func deleteReply(visualizationID: String, commentID: String, replyID: String) async throws {}
}

private struct DummyRepoError: Error, Equatable {}

// MARK: - Helpers

/// Returns a real 1x1 UIImage whose `pngData()` is non-nil.
private func makeValidImage() -> UIImage {
    let size = CGSize(width: 1, height: 1)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { ctx in
        UIColor.red.setFill()
        ctx.fill(CGRect(origin: .zero, size: size))
    }
}

/// Returns an empty UIImage whose `pngData()` is nil — used to trigger the conversion error.
private func makeInvalidImage() -> UIImage {
    UIImage()
}

// MARK: - UploadSnipUseCase

final class UploadSnipUseCaseTests: XCTestCase {

    // SNIP-002 — happy path
    @MainActor
    func test_execute_returnsURL_andCallsRepositoryOnce() async throws {
        let repo = SnippingToolTestsMockSnipRepository()
        let sut = UploadSnipUseCase(snipRepository: repo)

        let url = try await sut.execute(
            image: makeValidImage(),
            userID: "user-123",
            visualizationID: "viz-abc"
        )

        XCTAssertEqual(repo.uploadCallCount, 1)
        XCTAssertEqual(url, repo.stubbedURL)
        XCTAssertNotNil(repo.receivedData)
        XCTAssertFalse(repo.receivedData!.isEmpty)
    }

    // Path format: "snips/{userID}/{visualizationID}_{timestamp}.png"
    @MainActor
    func test_execute_buildsNamespacedStoragePath() async throws {
        let repo = SnippingToolTestsMockSnipRepository()
        let sut = UploadSnipUseCase(snipRepository: repo)

        _ = try await sut.execute(
            image: makeValidImage(),
            userID: "user-123",
            visualizationID: "viz-abc"
        )

        let path = try XCTUnwrap(repo.receivedPath)
        XCTAssertTrue(path.hasPrefix("snips/user-123/viz-abc_"))
        XCTAssertTrue(path.hasSuffix(".png"))

        // The timestamp segment must be numeric.
        let timestampSegment = path
            .replacingOccurrences(of: "snips/user-123/viz-abc_", with: "")
            .replacingOccurrences(of: ".png", with: "")
        XCTAssertNotNil(Int(timestampSegment), "Timestamp must be an integer, got: \(timestampSegment)")
    }

    // SNIP-003 — PNG conversion fails
    @MainActor
    func test_execute_whenPNGConversionFails_throwsImageConversionFailed() async {
        let repo = SnippingToolTestsMockSnipRepository()
        let sut = UploadSnipUseCase(snipRepository: repo)

        do {
            _ = try await sut.execute(
                image: makeInvalidImage(),
                userID: "user-123",
                visualizationID: "viz-abc"
            )
            XCTFail("Expected SnipUploadError.imageConversionFailed")
        } catch let error as SnipUploadError {
            switch error {
            case .imageConversionFailed:
                XCTAssertEqual(repo.uploadCallCount, 0, "Repository must not be called when conversion fails")
            }
        } catch {
            XCTFail("Expected SnipUploadError, got \(error)")
        }
    }

    // Repository error must propagate untouched.
    @MainActor
    func test_execute_whenRepositoryThrows_propagatesError() async {
        let repo = SnippingToolTestsMockSnipRepository()
        repo.stubbedError = DummyRepoError()
        let sut = UploadSnipUseCase(snipRepository: repo)

        do {
            _ = try await sut.execute(
                image: makeValidImage(),
                userID: "user-123",
                visualizationID: "viz-abc"
            )
            XCTFail("Expected repository error to propagate")
        } catch is DummyRepoError {
            // Expected
        } catch {
            XCTFail("Expected DummyRepoError, got \(error)")
        }
    }
}

// MARK: - PostSnipCommentUseCase

final class PostSnipCommentUseCaseTests: XCTestCase {

    // SNIP-002 — happy path (the Firestore write side)
    @MainActor
    func test_execute_forwardsAllParametersToRepository() async throws {
        let repo = SnippingToolTestsMockCommentRepository()
        let sut = PostSnipCommentUseCase(commentRepository: repo)
        let url = URL(string: "https://storage.example.com/snip.png")!

        try await sut.execute(
            visualizationID: "viz-abc",
            authorID: "user-123",
            imageURL: url,
            authorName: "Nico",
            caption: "Test caption"
        )

        XCTAssertEqual(repo.postSnipCallCount, 1)
        XCTAssertEqual(repo.receivedVisualizationID, "viz-abc")
        XCTAssertEqual(repo.receivedAuthorID, "user-123")
        XCTAssertEqual(repo.receivedImageURL, url)
        XCTAssertEqual(repo.receivedAuthorName, "Nico")
    }

    // Repository error must propagate untouched.
    @MainActor
    func test_execute_whenRepositoryThrows_propagatesError() async {
        let repo = SnippingToolTestsMockCommentRepository()
        repo.stubbedError = DummyRepoError()
        let sut = PostSnipCommentUseCase(commentRepository: repo)

        do {
            try await sut.execute(
                visualizationID: "viz-abc",
                authorID: "user-123",
                imageURL: URL(string: "https://x.example.com/x.png")!,
                authorName: "Nico",
                caption: "Test caption"
            )
            XCTFail("Expected repository error to propagate")
        } catch is DummyRepoError {
            // Expected
        } catch {
            XCTFail("Expected DummyRepoError, got \(error)")
        }
    }
}
