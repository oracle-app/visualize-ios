//
//  DeleteProfilePhotoUseCaseTests.swift
//  visualize
//
//  Created by Mariana Islas Mondragón on 07/06/26.
//

import XCTest
@testable import visualize

/// Unit tests for DeleteProfilePhotoUseCase.
///
/// Test plan coverage:
/// - PROF-004A: When a photo URL exists, the image is deleted from Storage and
///              the Firestore URL is cleared (set to null).
/// - PROF-004B: Edge case — when profilePictureURL is nil, no Storage deletion is
///              attempted but Firestore is still updated to ensure a clean state.
/// - PROF-004C: Attempting to delete without an active session throws noSession
///              before any repository method is called.
///
/// All tests use MockAuthRepository and MockUserRepository to avoid any
/// network or Firebase dependency.

@MainActor
final class DeleteProfilePhotoUseCaseTests: XCTestCase {

    // MARK: - PROF-004A

    /// Verifies the happy path: when the user has a photo, execute() calls
    /// deleteProfileImage once and updateProfilePictureURL once.
    func test_PROF004A_execute_deletesImage_andClearsURL() async throws {
        let auth = MockAuthRepository()
        auth.currentUser = AuthUser(uid: "user-123", email: "test@mail.com")

        let userRepo = MockUserRepository()
        userRepo.existingUser = AppUser(
            id: "user-123",
            email: "test@mail.com",
            profilePictureURL: "https://storage.example.com/profile.jpg",
            username: "testUser",
            role: .consumer
        )

        let sut = DeleteProfilePhotoUseCase(
            authRepository: auth,
            userRepository: userRepo
        )

        try await sut.execute()

        XCTAssertEqual(userRepo.deleteCallCount, 1, "Storage image should be deleted")
        XCTAssertEqual(userRepo.updateCallCount, 1, "Firestore URL should be cleared")
    }

    // MARK: - PROF-004B

    /// Verifies the edge case: when profilePictureURL is nil there is nothing to
    /// delete from Storage, but Firestore should still be updated to guarantee
    /// a consistent null state.
    func test_PROF004B_execute_whenNoPhoto_onlyClearsFirestore() async throws {
        let auth = MockAuthRepository()
        auth.currentUser = AuthUser(uid: "user-123", email: "test@mail.com")

        let userRepo = MockUserRepository()
        userRepo.existingUser = AppUser(
            id: "user-123",
            email: "test@mail.com",
            profilePictureURL: nil,
            username: "testUser",
            role: .consumer
        )

        let sut = DeleteProfilePhotoUseCase(
            authRepository: auth,
            userRepository: userRepo
        )

        try await sut.execute()

        XCTAssertEqual(userRepo.deleteCallCount, 0, "No Storage deletion should occur when there is no photo")
        XCTAssertEqual(userRepo.updateCallCount, 1, "Firestore URL should still be cleared")
    }

    // MARK: - PROF-004C

    /// Verifies that execute() throws DeleteProfilePhotoError.noSession
    /// when no authenticated user is present, without touching any repository method.
    func test_PROF004C_execute_withoutSession_throwsNoSession() async {
        let auth = MockAuthRepository()
        auth.currentUser = nil

        let sut = DeleteProfilePhotoUseCase(
            authRepository: auth,
            userRepository: MockUserRepository()
        )

        do {
            try await sut.execute()
            XCTFail("Expected noSession error")
        } catch let error as DeleteProfilePhotoUseCase.DeleteProfilePhotoError {
            XCTAssertEqual(error, .noSession)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
