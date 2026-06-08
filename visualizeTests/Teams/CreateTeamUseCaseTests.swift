//
//  CreateTeamUseCaseTests.swift
//  visualize
//
//  Created by Diana Escalante on 07/06/26.
//

import XCTest
@testable import visualize

///  Unit tests for CreateTeamUseCase: name validation, member validation,
///  whitespace trimming, owner deduping.
///
///  Test plan coverage:
///  - TEAM-001: Create team with valid name and members
///  - TEAM-002: Empty name throws CreateTeamError.teamNameEmpty
///  - TEAM-003: No members throws CreateTeamError.teamMembersEmpty
///  - TEAM-004: Team name whitespace is trimmed before persisting
///  - TEAM-005: Owner ID is removed from initialMembers and duplicates collapsed

@MainActor
final class CreateTeamUseCaseTests: XCTestCase {

    // TEAM-001
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

    // TEAM-002
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

    // TEAM-003
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

    // TEAM-004
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

    // TEAM-005
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
