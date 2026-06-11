//
//  EditTeamScreenViewModelTests.swift
//  visualize
//
//  Created by Diana Escalante on 07/06/26.
//

import XCTest
@testable import visualize

///  Unit tests for EditTeamScreenViewModel.confirmChanges: persists the updated
///  members list without rewriting the owner, and propagates repository errors.
///
///  Test plan coverage:
///  - TEAM-006: Editing an existing team persists the updated members list

@MainActor
final class EditTeamScreenViewModelTests: XCTestCase {

    // TEAM-006
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

    // TEAM-006 — error propagation
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
