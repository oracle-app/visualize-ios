//
//  MockUserRepository.swift
//  visualize
//
//  Created by Diana Escalante on 07/06/26.
//

import Foundation

// MARK: - MockUserRepository
/// Mock implementation of UserRepository for use in SwiftUI previews and UI tests.
/// Returns a hardcoded writer user so screens that depend on role-based rendering
/// (e.g. TeamsScreen) display their full layout without a Firestore round-trip.

final class MockUserRepository: UserRepository {

    func getUserByID(userID: String) async throws -> AppUser {
        AppUser(
            id: userID,
            email: "preview@example.com",
            profilePictureURL: nil,
            username: "Preview User",
            role: .writer
        )
    }

    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] { [] }

    func createUser(user: AppUser) async throws -> AppUser { user }

    func addHiddenVisualization(userID: String, visualizationID: String) async throws {}

    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {}

    func updateProfilePictureURL(userID: String, url: URL?) async throws {}
    
    func deleteProfileImage(byURL url: URL) async throws {}

    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL {
        URL(string: "https://example.com/preview.png")!
    }

    func deleteProfileImage(userID: String) async throws {}
}
