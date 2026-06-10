//
//  MockProfileUseCases.swift
//  visualize
//
//  Created by Mariana Islas Mondragón on 07/06/26.
//

#if DEBUG
import UIKit
import Foundation
/// Lightweight test doubles for the Profile feature's use cases.
///
/// These mocks are used exclusively by:
///   - ProfileUITests (via the -uitest-profile launch argument)
///   - The ProfileScreen #Preview in DEBUG builds
///
/// Every override short-circuits the real implementation so no network call,
/// Firebase read, or Storage upload is ever triggered during UI tests or Previews.
///
/// Auth dependencies are satisfied by the shared MockAuthRepository defined in
/// MockAuthRepositories.swift, which is already used across all feature unit tests.

// MARK: - MockUserRepositoryProfile

/// Stub user repository that returns a hardcoded AppUser and no-ops all write operations.
/// uploadProfileImage returns a fake Storage URL so the ViewModel can update
/// profilePictureURL without hitting Firebase.
final class MockUserRepositoryProfile: UserRepository {
    func getUserByID(userID: String) async throws -> AppUser {
        AppUser(
            id: "mock-uid",
            email: "mariana@test.com",
            profilePictureURL: nil,
            username: "Mariana Test",
            role: .consumer
        )
    }
    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL {
        URL(string: "https://mock.storage/photo.jpg")!
    }
    func updateProfilePictureURL(userID: String, url: URL?) async throws {}
    func deleteProfileImage(byURL url: URL) async throws {}
    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] { [] }
    func createUser(user: AppUser) async throws -> AppUser { user }
    func addHiddenVisualization(userID: String, visualizationID: String) async throws {}
    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {}
}

// MARK: - MockLogoutUseCase

/// No-op logout — prevents the coordinator from navigating away during UI tests.
final class MockLogoutUseCase: LogoutUseCase {
    init() {
        super.init(repository: MockAuthRepository())
    }
    override func execute() throws {}
}

// MARK: - MockGetCurrentUserProfileUseCase

/// Returns a fixed AppUser without touching auth or Firestore.
/// The override guarantees the mock repositories injected at init are never reached,
/// so the returned user is always deterministic regardless of repository state.
final class MockGetCurrentUserProfileUseCase: GetCurrentUserProfileUseCase {
    init() {
        super.init(
            authRepository: MockAuthRepository(),
            userRepository: MockUserRepositoryProfile()
        )
    }
    override func execute() async throws -> AppUser {
        AppUser(
            id: "mock-uid",
            email: "mariana@test.com",
            profilePictureURL: nil,
            username: "Mariana Test",
            role: .consumer
        )
    }
}

// MARK: - MockUploadProfilePhotoUseCase

/// Simulates a successful photo upload by returning a fake Storage URL immediately.
/// No image data is processed and no network request is made.
final class MockUploadProfilePhotoUseCase: UploadProfilePhotoUseCase {
    init() {
        super.init(
            authRepository: MockAuthRepository(),
            userRepository: MockUserRepositoryProfile()
        )
    }
    override func execute(imageData: Data) async throws -> URL {
        URL(string: "https://mock.storage/photo.jpg")!
    }
}

// MARK: - MockDeleteProfilePhotoUseCase

/// Simulates a successful photo deletion without touching Storage or Firestore.
final class MockDeleteProfilePhotoUseCase: DeleteProfilePhotoUseCase {
    init() {
        super.init(
            authRepository: MockAuthRepository(),
            userRepository: MockUserRepositoryProfile()
        )
    }
    override func execute() async throws {}
}

#endif
