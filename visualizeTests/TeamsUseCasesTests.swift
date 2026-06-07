//
//  TeamsUseCasesTests.swift
//  visualize
//
//  Created by Diana Escalante on 07/06/26.
//

import XCTest
@testable import visualize

// swiftlint:disable orphaned_doc_comment

///  Unit tests for the Teams flow:
///  - CreateTeamUseCase  (name validation, member validation, owner deduping, trimming)
///  - EditTeamScreenViewModel.confirmChanges  (update path)
///
///  Test plan coverage:
///  - TEAM-001: Create team with valid name and members
///  - TEAM-002: Create team with empty name -> CreateTeamError.teamNameEmpty
///  - TEAM-003: Create team with no members -> CreateTeamError.teamMembersEmpty
///  - TEAM-004: Team name with surrounding whitespace is trimmed before persisting
///  - TEAM-005: Owner is not duplicated in initialMembers
///  - TEAM-006: Editing an existing team persists the updated members list

// swiftlint:enable orphaned_doc_comment

// MARK: - Mocks
private final class MockTeamRepositorySpy: TeamRepository {

    // createTeam
    var createCallCount = 0
    var receivedName: String?
    var receivedOwnerID: String?
    var receivedInitialMembers: [String]?
    var stubbedCreateError: Error?

    // updateTeamMembers
    var updateCallCount = 0
    var receivedTeamID: String?
    var receivedMembersIDs: [String]?
    var stubbedUpdateError: Error?

    func createTeam(name: String, ownerID: String, initialMembers: [String]) async throws {
        createCallCount += 1
        receivedName = name
        receivedOwnerID = ownerID
        receivedInitialMembers = initialMembers
        if let error = stubbedCreateError { throw error }
    }

    func updateTeamMembers(teamID: String, membersIDs: [String]) async throws {
        updateCallCount += 1
        receivedTeamID = teamID
        receivedMembersIDs = membersIDs
        if let error = stubbedUpdateError { throw error }
    }

    // Unused in these tests — stubbed to satisfy the protocol.
    func getTeamsUserIsIn(userID: String) async throws -> [Team] { [] }
    func getTeamsUserOwns(userID: String) async throws -> [Team] { [] }
    func deleteTeam(teamID: String) async throws {}
}

private final class StubUserRepository: UserRepository {
    func getUserByID(userID: String) async throws -> AppUser {
        AppUser(id: userID, email: "x@x.com", profilePictureURL: nil, username: "x", role: .writer)
    }
    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] { [] }
    func createUser(user: AppUser) async throws -> AppUser { user }
    func addHiddenVisualization(userID: String, visualizationID: String) async throws {}
    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {}
    func updateProfilePictureURL(userID: String, url: URL?) async throws {}
    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL {
        URL(string: "https://x.example.com/x.png")!
    }
    func deleteProfileImage(userID: String) async throws {}
}

// MARK: - Helpers

private func makeUser(_ id: String) -> AppUser {
    AppUser(
        id: id,
        email: "\(id)@example.com",
        profilePictureURL: nil,
        username: id,
        role: .writer
    )
}

// MARK: - CreateTeamUseCase

@MainActor
final class CreateTeamUseCaseTests: XCTestCase {

    // TEAM-001 — happy path
    func test_execute_withValidNameAndMembers_callsRepositoryWithOwnerImplicit() async throws {
        let repo = MockTeamRepositorySpy()
        let sut = CreateTeamUseCase(teamRepository: repo)

        try await sut.execute(
            name: "Design Team",
            ownerID: "owner-1",
            memberIDs: ["u2", "u3"]
        )

        XCTAssertEqual(repo.createCallCount, 1)
        XCTAssertEqual(repo.receivedName, "Design Team")
        XCTAssertEqual(repo.receivedOwnerID, "owner-1")
        // initialMembers is the non-owner list. The owner is added by the
        // repository/datasource layer, not by the use case.
        XCTAssertEqual(repo.receivedInitialMembers, ["u2", "u3"])
    }

    // TEAM-002 — empty name
    func test_execute_withEmptyName_throwsTeamNameEmpty_andDoesNotCallRepository() async {
        let repo = MockTeamRepositorySpy()
        let sut = CreateTeamUseCase(teamRepository: repo)

        do {
            try await sut.execute(name: "   ", ownerID: "owner-1", memberIDs: ["u2"])
            XCTFail("Expected CreateTeamError.teamNameEmpty")
        } catch CreateTeamError.teamNameEmpty {
            XCTAssertEqual(repo.createCallCount, 0)
        } catch {
            XCTFail("Expected CreateTeamError.teamNameEmpty, got \(error)")
        }
    }

    // TEAM-003 — no non-owner members
    func test_execute_withNoMembers_throwsTeamMembersEmpty_andDoesNotCallRepository() async {
        let repo = MockTeamRepositorySpy()
        let sut = CreateTeamUseCase(teamRepository: repo)

        do {
            try await sut.execute(name: "Design Team", ownerID: "owner-1", memberIDs: [])
            XCTFail("Expected CreateTeamError.teamMembersEmpty")
        } catch CreateTeamError.teamMembersEmpty {
            XCTAssertEqual(repo.createCallCount, 0)
        } catch {
            XCTFail("Expected CreateTeamError.teamMembersEmpty, got \(error)")
        }
    }

    // TEAM-004 — name is trimmed
    func test_execute_trimsWhitespaceFromName() async throws {
        let repo = MockTeamRepositorySpy()
        let sut = CreateTeamUseCase(teamRepository: repo)

        try await sut.execute(
            name: "   Mi Equipo   ",
            ownerID: "owner-1",
            memberIDs: ["u2"]
        )

        XCTAssertEqual(repo.receivedName, "Mi Equipo")
    }

    // TEAM-005 — owner is removed from initialMembers if duplicated, and duplicates collapsed
    func test_execute_removesOwnerAndDuplicatesFromInitialMembers() async throws {
        let repo = MockTeamRepositorySpy()
        let sut = CreateTeamUseCase(teamRepository: repo)

        try await sut.execute(
            name: "Design Team",
            ownerID: "owner-1",
            memberIDs: ["owner-1", "u2", "u2", "u3"]
        )

        let received = try XCTUnwrap(repo.receivedInitialMembers)
        XCTAssertFalse(received.contains("owner-1"), "Owner must not appear in initialMembers")
        XCTAssertEqual(received, ["u2", "u3"], "Duplicates must be collapsed in declaration order")
    }
}

// MARK: - EditTeamScreenViewModel

@MainActor
final class EditTeamScreenViewModelTests: XCTestCase {

    // TEAM-006 — editing persists the updated, non-owner members list
    func test_confirmChanges_callsUpdateTeamMembers_withoutOwner() async throws {
        let repo = MockTeamRepositorySpy()
        let sut = EditTeamScreenViewModel(
            teamRepository: repo,
            userRepository: StubUserRepository(),
            teamID: "team-1",
            ownerID: "owner-1",
            initialMembers: [makeUser("owner-1"), makeUser("u2"), makeUser("u3")]
        )

        // Simulate the user adding a new member and removing one.
        sut.addUser(makeUser("u4"))
        sut.removeUser(makeUser("u2"))

        try await sut.confirmChanges()

        XCTAssertEqual(repo.updateCallCount, 1)
        XCTAssertEqual(repo.receivedTeamID, "team-1")
        let ids = try XCTUnwrap(repo.receivedMembersIDs)
        XCTAssertFalse(ids.contains("owner-1"), "Owner must not be written back into membersIDs")
        XCTAssertEqual(Set(ids), Set(["u3", "u4"]))
    }

    // TEAM-006 — error propagates so the screen can stay open
    func test_confirmChanges_whenRepositoryThrows_propagatesError() async {
        let repo = MockTeamRepositorySpy()
        repo.stubbedUpdateError = NSError(domain: "test", code: 1)
        let sut = EditTeamScreenViewModel(
            teamRepository: repo,
            userRepository: StubUserRepository(),
            teamID: "team-1",
            ownerID: "owner-1",
            initialMembers: [makeUser("owner-1"), makeUser("u2")]
        )

        do {
            try await sut.confirmChanges()
            XCTFail("Expected repository error to propagate")
        } catch {
            // Expected.
        }
    }
}
