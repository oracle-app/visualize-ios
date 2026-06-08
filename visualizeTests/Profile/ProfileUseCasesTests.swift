//
//  ProfileUseCasesTests.swift
//  visualize
//
//  Created by Mariana Islas Mondragón on 07/06/26.
//

import XCTest
@testable import visualize

/// Unit tests for UploadProfilePhotoUseCase.
///
/// Test plan coverage:
/// - PROF-002: A valid image is uploaded to Storage and the Firestore URL is updated.
/// - PROF-005: Attempting to upload without an active session throws noSession.
/// - PROF-006: If the Firestore update fails after a successful upload, the uploaded
///             image is deleted from Storage (rollback) and the error is propagated.
///
/// All tests use MockAuthRepository and TestsProfileMockUserRepository to avoid any
/// network or Firebase dependency. Execution is fully synchronous from the
/// test runner's perspective via async/await.

// MARK: - Helpers

/// Generic error used to trigger failure paths in mock repositories.
struct DummyError: Error, Equatable {}

/// Returns minimal valid image data accepted by the use case under test.
func makeValidData() -> Data {
    Data("fake-image".utf8)
}

// MARK: - Tests

@MainActor
final class UploadProfilePhotoUseCaseTests: XCTestCase {

    // MARK: - PROF-002

    /// Verifies the happy path: execute() calls uploadProfileImage once,
    /// updateProfilePictureURL once, and returns the stubbed Storage URL.
    func test_PROF002_execute_uploadsImage_andUpdatesProfile() async throws {
        let auth = MockAuthRepository()
        auth.currentUser = AuthUser(uid: "user-123", email: "test@mail.com")

        let userRepo = TestsProfileMockUserRepository()
        userRepo.existingUser = AppUser(
            id: "user-123",
            email: "test@mail.com",
            profilePictureURL: "https://old-url.com/image.jpg",
            username: "testUser",
            role: .consumer
        )

        let sut = UploadProfilePhotoUseCase(
            authRepository: auth,
            userRepository: userRepo
        )

        let url = try await sut.execute(imageData: makeValidData())

        XCTAssertEqual(userRepo.uploadCallCount, 1)
        XCTAssertEqual(userRepo.updateCallCount, 1)
        XCTAssertEqual(url, userRepo.stubbedUploadURL)
    }

    // MARK: - PROF-005

    /// Verifies that execute() throws UploadProfilePhotoError.noSession
    /// when no authenticated user is present, without touching the repository.
    func test_PROF005_execute_withoutSession_throwsNoSession() async throws {
        let auth = MockAuthRepository()
        auth.currentUser = nil

        let sut = UploadProfilePhotoUseCase(
            authRepository: auth,
            userRepository: TestsProfileMockUserRepository()
        )

        do {
            _ = try await sut.execute(imageData: makeValidData())
            XCTFail("Expected noSession error")
        } catch let error as UploadProfilePhotoUseCase.UploadProfilePhotoError {
            XCTAssertEqual(error, .noSession)
        }
    }

    // MARK: - PROF-006

    /// Verifies the rollback path: when updateProfilePictureURL fails after a
    /// successful upload, the use case must delete the orphaned Storage image
    /// (deleteCallCount == 1) and propagate the error to the caller.
    func test_PROF006_execute_whenUpdateFails_rollsBackUpload() async throws {
        let auth = MockAuthRepository()
        auth.currentUser = AuthUser(uid: "user-123", email: "test@mail.com")

        let userRepo = TestsProfileMockUserRepository()
        userRepo.existingUser = AppUser(
            id: "user-123",
            email: "test@mail.com",
            profilePictureURL: "https://old-url.com/image.jpg",
            username: "testUser",
            role: .consumer
        )
        userRepo.failOnUpdate = true

        let sut = UploadProfilePhotoUseCase(
            authRepository: auth,
            userRepository: userRepo
        )

        do {
            _ = try await sut.execute(imageData: makeValidData())
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(userRepo.uploadCallCount, 1, "Image should have been uploaded before the failure")
            XCTAssertEqual(userRepo.deleteCallCount, 1, "Orphaned image should be deleted as rollback")
        }
    }
}
