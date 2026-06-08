//
//  MockTeamRepositorySpy.swift
//  visualize
//
//  Created by Diana Escalante on 07/06/26.
//

import Foundation
@testable import visualize

///  Test double for TeamRepository that records every call it receives,
///  so unit tests can assert how the system under test interacted with it.

final class MockTeamRepositorySpy: TeamRepository {

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

    // Unused in current tests — stubbed to satisfy the protocol.
    func getTeamsUserIsIn(userID: String) async throws -> [Team] { [] }
    func getTeamsUserOwns(userID: String) async throws -> [Team] { [] }
    func deleteTeam(teamID: String) async throws {}
}
