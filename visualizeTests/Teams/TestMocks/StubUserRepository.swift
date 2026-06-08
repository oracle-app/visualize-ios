//
//  StubUserRepository.swift
//  visualize
//
//  Created by Diana Escalante on 07/06/26.
//

import Foundation
@testable import visualize

/// Empty UserRepository implementation that exists only to satisfy
///  initializers that require one. Tests using this stub never read
///  the returned values — they assert against other collaborators.

final class StubUserRepository: UserRepository {

    func getUserByID(userID: String) async throws -> AppUser {
        AppUser(
            id: userID,
            email: "stub@example.com",
            profilePictureURL: nil,
            username: "stub",
            role: .writer
        )
    }

    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] { [] }

    func createUser(user: AppUser) async throws -> AppUser { user }

    func addHiddenVisualization(userID: String, visualizationID: String) async throws {}

    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {}

    func updateProfilePictureURL(userID: String, url: URL?) async throws {}

    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL {
        URL(string: "https://example.com/stub.png")!
    }

    func deleteProfileImage(byURL url: URL) async throws {}
}

// MARK: - Test helpers

func makeUser(_ id: String) -> AppUser {
    AppUser(
        id: id,
        email: "\(id)@example.com",
        profilePictureURL: nil,
        username: id,
        role: .writer
    )
}
