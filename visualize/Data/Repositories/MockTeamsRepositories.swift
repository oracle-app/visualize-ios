//
//  MockTeamsRepositories.swift
//  visualize
//
//  Created by Diana Escalante on 19/05/26.
//

// MARK: - MockTeamRepository
/// Mock implementation of TeamRepository for use in SwiftUI previews.
/// Returns hardcoded data without requiring a Firebase connection.

final class MockTeamRepository: TeamRepository {

    private let mockMembers: [AppUser] = [
        AppUser(id: "u1", email: "ana@example.com", profilePictureURL: nil, username: "Ana García"),
        AppUser(id: "u2", email: "luis@example.com", profilePictureURL: nil, username: "Luis Pérez"),
        AppUser(id: "u3", email: "maria@example.com", profilePictureURL: nil, username: "María López"),
        AppUser(id: "u4", email: "carlos@example.com", profilePictureURL: nil, username: "Carlos Ruiz")
    ]

    func getTeamsUserOwns(userID: String) async throws -> [Team] {
        [
            Team(id: "t1", name: "Design Team", memberCount: 3, members: Array(mockMembers.prefix(3))),
            Team(id: "t2", name: "Backend Crew", memberCount: 2, members: Array(mockMembers.prefix(2)))
        ]
    }

    func getTeamsUserIsIn(userID: String) async throws -> [Team] {
        [
            Team(id: "t3", name: "Marketing", memberCount: 4, members: mockMembers),
            Team(id: "t4", name: "QA Squad", memberCount: 1, members: Array(mockMembers.prefix(1)))
        ]
    }

    func createTeam(name: String, ownerID: String, initialMembers: [String]) async throws {}

    func deleteTeam(teamID: String) async throws {}
}

// MARK: - MockAuthRepository
/// Mock implementation of AuthRepository for use in SwiftUI previews.
/// Returns a hardcoded user ID without requiring a Firebase session.

final class MockAuthRepository: AuthRepository {

    func getCurrentUserID() async throws -> String { "preview-user-id" }

    func login(email: String, password: String) async throws -> AuthUser {
        AuthUser(uid: "preview-user-id", email: email)
    }

    func register(email: String, password: String) async throws -> AuthUser {
        AuthUser(uid: "preview-user-id", email: email)
    }

    func logout() throws {}

    func getCurrentUser() -> AuthUser? {
        AuthUser(uid: "preview-user-id", email: "preview@example.com")
    }

    func deleteCurrentUser() async throws {}

    func sendPasswordReset(to email: String) async throws {}
}
