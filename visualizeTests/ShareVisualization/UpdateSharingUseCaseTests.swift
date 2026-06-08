//
//  UpdateSharingUseCaseTests.swift
//  visualize
//
//  Created by Carlos Amador on 07/06/26.
//

import XCTest
@testable import visualize

// MARK: - UpdateSharingUseCaseTests

final class UpdateSharingUseCaseTests: XCTestCase {

    var visualizationRepo: MockVisualizationRepository!
    var userRepo: MockUserRepository!
    var sut: UpdateSharingUseCase!

    override func setUp() {
        super.setUp()
        visualizationRepo = MockVisualizationRepository()
        userRepo = MockUserRepository()
        sut = UpdateSharingUseCase(visualizationRepository: visualizationRepo, userRepository: userRepo)
    }

    // SHAR-001 y SHAR-002: Share visualization with user and team
    @MainActor
    func test_execute_updatesSharedWithUsersAndTeams() async throws {

        let mockUser = AppUser(id: "user-1", email: "User1", profilePictureURL: "", username: "user1@test.com", role: .writer)
        let mockTeamMember = AppUser(id: "user-2", email: "User2", profilePictureURL: "", username: "use21@test.com", role: .writer)
        let mockTeam = Team(id: "team-1", name: "Team 1", ownerID: "owner-1", memberCount: 1, members: [mockTeamMember])
        
        let vizID = "viz-123"

        let result = try await sut.execute(
            visualizationID: vizID,
            users: [mockUser],
            teamIDs: ["team-1"],
            teams: [mockTeam]
        )

        // Assert SHAR-001
        XCTAssertEqual(visualizationRepo.updateSharingCallCount, 1)
        XCTAssertEqual(visualizationRepo.receivedVisualizationID, vizID)
        XCTAssertEqual(visualizationRepo.receivedUserIDs, ["user-1"])
        
        // Assert SHAR-002
        XCTAssertEqual(visualizationRepo.receivedTeamIDs, ["team-1"])
        
        // Verify returns
        XCTAssertEqual(result.users.map { $0.id }, ["user-1"])
        XCTAssertEqual(result.teamIDs, ["team-1"])
    }

    // SHAR-003: Update shared users lists
    @MainActor
    func test_execute_removesHiddenVisualizationsForDirectUsersAndTeamMembers() async throws {
        // Arrange
        let directUser = AppUser(id: "user-1", email: "User1", profilePictureURL: "", username: "user1@test.com", role: .writer)
        let teamMember1 = AppUser(id: "user-2", email: "User2", profilePictureURL: "", username: "user2@test.com", role: .writer)
        let team = Team(id: "team-1", name: "Team 1", ownerID: "owner-1", memberCount: 2, members: [directUser, teamMember1])
        
        let vizID = "viz-123"

        // Act
        _ = try await sut.execute(
            visualizationID: vizID,
            users: [directUser],
            teamIDs: ["team-1"],
            teams: [team]
        )

        // Assert SHAR-003
        XCTAssertEqual(userRepo.removeHiddenCallCount, 2)
        
        let removedIDs = userRepo.removedHiddenVisualizations.map { $0.userID }
        
        XCTAssertTrue(removedIDs.contains("user-1"))
        XCTAssertTrue(removedIDs.contains("user-2"))
        
        let removedVizIDs = userRepo.removedHiddenVisualizations.map { $0.visualizationID }
        XCTAssertTrue(removedVizIDs.allSatisfy { $0 == vizID })
    }
}
