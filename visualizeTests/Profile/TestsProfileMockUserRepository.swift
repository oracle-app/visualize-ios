//
//  MockUserRepositoryTests.swift
//  visualize
//
//  Created by Mariana Islas Mondragón on 07/06/26.
//

import Foundation
@testable import visualize

/// Configurable test double for UserRepository used across Profile unit tests.
///
/// Call counters (uploadCallCount, updateCallCount, deleteCallCount, getUserCallCount)
/// let tests assert that use cases invoke the right repository methods the expected
/// number of times without inspecting internal state.
///
/// Failure flags (failOnUpload, failOnUpdate) trigger DummyError on the corresponding
/// method to exercise error-handling and rollback paths in use cases.
///
/// existingUser must be set before any test that calls getUserByID; force-unwrapping
/// is intentional so a missing setup causes an immediate, obvious test crash rather
/// than a silent wrong-data failure.
final class TestsProfileMockUserRepository: UserRepository {

    // MARK: - Call counters

    var uploadCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0
    var getUserCallCount = 0

    // MARK: - Stubs and failure flags

    /// URL returned by uploadProfileImage on success.
    var stubbedUploadURL = URL(string: "https://storage.example.com/profile.jpg")!

    /// When true, uploadProfileImage throws DummyError instead of returning the stubbed URL.
    var failOnUpload = false

    /// When true, updateProfilePictureURL throws DummyError to simulate a Firestore write failure.
    var failOnUpdate = false

    /// User returned by getUserByID. Must be set before tests that trigger a profile fetch.
    var existingUser: AppUser?

    // MARK: - UserRepository

    func getUserByID(userID: String) async throws -> AppUser {
        getUserCallCount += 1
        return existingUser!
    }

    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL {
        uploadCallCount += 1
        if failOnUpload { throw DummyError() }
        return stubbedUploadURL
    }

    func updateProfilePictureURL(userID: String, url: URL?) async throws {
        updateCallCount += 1
        if failOnUpdate { throw DummyError() }
    }

    func deleteProfileImage(byURL url: URL) async throws {
        deleteCallCount += 1
    }

    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] { [] }
    func createUser(user: AppUser) async throws -> AppUser { user }
    func addHiddenVisualization(userID: String, visualizationID: String) async throws {}
    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {}
}
