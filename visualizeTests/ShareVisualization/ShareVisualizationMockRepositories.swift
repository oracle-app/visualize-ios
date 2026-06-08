//
//  ShareVisualizationMockRepositories.swift
//  visualize
//
//  Created by Carlos Amador on 07/06/26.
//

import XCTest
@testable import visualize

// MARK: - Mock Errors

enum MockError: Error {
    case unimplemented
}

// MARK: - Mocks

final class SharingTestsMockVisualizationRepository: VisualizationRepository {
    func getAllVisualizations(userID: String) async throws -> [visualize.VisualizationCard] {
        XCTFail("getAllVisualizations(userID:) was called but is not implemented.")
        throw MockError.unimplemented
    }
    
    func searchVisualizations(userID: String, query: String) async throws -> [visualize.VisualizationCard] {
        XCTFail("searchVisualizations(userID:query:) was called but is not implemented.")
        throw MockError.unimplemented
    }
    
    func deleteVisualization(visualizationID: String) async throws {}
    
    func removeUserFromSharedWith(visualizationID: String, userID: String) async throws {}
    
    func createVisualization(title: String, authorID: String, configJSON: String, previewJSON: String, userIDs: [String], teamIDs: [String]) async throws {}
    
    func fetchConfigJSON(visualizationID: String) async throws -> String? {
        XCTFail("fetchConfigJSON(visualizationID:) was called but is not implemented.")
        throw MockError.unimplemented
    }
    
    var updateSharingCallCount = 0
    var receivedVisualizationID: String?
    var receivedUserIDs: [String]?
    var receivedTeamIDs: [String]?
    var stubbedError: Error?

    func updateSharing(visualizationID: String, userIDs: [String], teamIDs: [String]) async throws {
        updateSharingCallCount += 1
        receivedVisualizationID = visualizationID
        receivedUserIDs = userIDs
        receivedTeamIDs = teamIDs
        if let error = stubbedError { throw error }
    }
}

final class SharingTestsMockUserRepository: UserRepository {
    var removeHiddenCallCount = 0
    var removedHiddenVisualizations: [(userID: String, visualizationID: String)] = []
    
    var searchEmailCallCount = 0
    var receivedSearchEmail: String?
    var stubbedSuggestedUsers: [AppUser] = []

    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {
        removeHiddenCallCount += 1
        removedHiddenVisualizations.append((userID, visualizationID))
    }
    
    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] {
        searchEmailCallCount += 1
        receivedSearchEmail = email
        return stubbedSuggestedUsers
    }
    
    func getUserByID(userID: String) async throws -> AppUser {
        XCTFail("getUserByID(userID:) was called but is not implemented.")
        throw MockError.unimplemented
    }
    
    func createUser(user: AppUser) async throws -> AppUser {
        XCTFail("createUser(user:) was called but is not implemented.")
        throw MockError.unimplemented
    }
    
    func addHiddenVisualization(userID: String, visualizationID: String) async throws {}
    func updateProfilePictureURL(userID: String, url: URL?) async throws {}
    func deleteProfileImage(byURL url: URL) async throws {}
    
    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL {
        XCTFail("uploadProfileImage(userID:imageData:) was called but is not implemented.")
        throw MockError.unimplemented
    }
}

final class SharingTestsMockAuthRepository: AuthRepository {
    func login(email: String, password: String) async throws -> visualize.AuthUser {
        XCTFail("login(email:password:) was called but is not implemented.")
        throw MockError.unimplemented
    }
    
    func register(email: String, password: String) async throws -> visualize.AuthUser {
        XCTFail("register(email:password:) was called but is not implemented.")
        throw MockError.unimplemented
    }
    
    func logout() throws {}
    
    func getCurrentUser() -> visualize.AuthUser? {
        XCTFail("getCurrentUser() was called but is not implemented.")
        return nil
    }
    
    func deleteCurrentUser() async throws {}
    
    func sendPasswordReset(to email: String) async throws {}
    
    var stubbedUserID = "current-user-123"
    func getCurrentUserID() async throws -> String { return stubbedUserID }
}

final class SharingTestsMockTeamRepository: TeamRepository {
    var stubbedMyTeams: [Team] = []
    var stubbedJoinedTeams: [Team] = []
    
    func getTeamsUserOwns(userID: String) async throws -> [Team] { stubbedMyTeams }
    func getTeamsUserIsIn(userID: String) async throws -> [Team] { stubbedJoinedTeams }
    
    func createTeam(name: String, ownerID: String, initialMembers: [String]) async throws {}
    func updateTeamMembers(teamID: String, membersIDs: [String]) async throws {}
    func deleteTeam(teamID: String) async throws {}
}
