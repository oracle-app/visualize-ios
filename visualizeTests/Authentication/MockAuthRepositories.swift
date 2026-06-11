//
//  MockAuthRepositories.swift
//  visualize
//
//  Created by Libia Fv on 06/06/26.
//
//  Shared mock stubs for authentication unit tests.
//  Import this file in your test target — all test files rely on these mocks.
//

import XCTest
@testable import visualize

// MARK: - MockAuthRepository

/// Configurable mock of AuthRepository.
/// Simulates successful responses and errors without touching Firebase.
final class MockAuthRepository: AuthRepository {

    // MARK: Login

    /// When `nil`, login returns `loginResult`. Otherwise throws the error.
    var loginError: Error?
    var loginResult: AuthUser = AuthUser(uid: "mock-uid", email: "test@example.com")

    func login(email: String, password: String) async throws -> AuthUser {
        if let error = loginError { throw error }
        return loginResult
    }

    // MARK: Register

    var registerError: Error?
    var registerResult: AuthUser = AuthUser(uid: "new-uid", email: "new@example.com")

    func register(email: String, password: String) async throws -> AuthUser {
        if let error = registerError { throw error }
        return registerResult
    }

    // MARK: Logout

    var logoutError: Error?
    var logoutCalled = false

    func logout() throws {
        logoutCalled = true
        if let error = logoutError { throw error }
    }

    // MARK: Misc

    var currentUser: AuthUser?
    func getCurrentUser() -> AuthUser? { currentUser }

    var deleteCurrentUserCalled = false
    func deleteCurrentUser() async throws { deleteCurrentUserCalled = true }

    var sendPasswordResetError: Error?
    var sendPasswordResetCalled = false

    func sendPasswordReset(to email: String) async throws {
        sendPasswordResetCalled = true
        if let error = sendPasswordResetError { throw error }
    }

    func getCurrentUserID() async throws -> String {
        guard let uid = currentUser?.uid else { throw LoginError.notFound }
        return uid
    }
}

// MARK: - MockUserRepositoryAuth

/// Configurable mock of UserRepository.
/// Only used in RegisterUseCase; all other methods are no-ops.
final class MockUserRepositoryAuth: UserRepository {

    var createUserError: Error?
    var createUserResult: AppUser?

    func createUser(user: AppUser) async throws -> AppUser {
        if let error = createUserError { throw error }
        return createUserResult ?? user
    }

    func getUserByID(userID: String) async throws -> AppUser {
        fatalError("Not needed in auth tests")
    }
    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] { [] }
    func addHiddenVisualization(userID: String, visualizationID: String) async throws {}
    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {}
    func updateProfilePictureURL(userID: String, url: URL?) async throws {}
    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL {
        fatalError("Not needed in auth tests")
    }
    func deleteProfileImage(byURL url: URL) async throws {}
}
