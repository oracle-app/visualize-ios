//
//  ShareTeammatesScreenViewModelTests.swift
//  visualize
//
//  Created by Carlos Amador on 07/06/26.
//

import XCTest
@testable import visualize

// MARK: - ShareTeammatesScreenViewModelTests

final class ShareTeammatesScreenViewModelTests: XCTestCase {

    var userRepo: MockUserRepository!
    var teamRepo: MockTeamRepository!
    var authRepo: MockAuthRepository!
    var visualizationRepo: MockVisualizationRepository!
    var useCase: UpdateSharingUseCase!
    var sut: ShareTeammatesScreenViewModel!

    override func setUp() {
        super.setUp()
        userRepo = MockUserRepository()
        teamRepo = MockTeamRepository()
        authRepo = MockAuthRepository()
        visualizationRepo = MockVisualizationRepository()
        
        useCase = UpdateSharingUseCase(visualizationRepository: visualizationRepo, userRepository: userRepo)
        
        sut = ShareTeammatesScreenViewModel(
            userRepository: userRepo,
            teamRepository: teamRepo,
            authRepository: authRepo,
            updateSharingUseCase: useCase,
            visualizationID: "viz-123"
        )
    }

    // SHAR-004: Search user by email
    // SHAR-004: Search user by email
        @MainActor
        func test_searchByEmail_whenMoreThanThreeCharacters_populatesSuggestedUsers() async throws {
            // Arrange
            let mockSuggestedUser = AppUser(id: "user-1", email: "User1", profilePictureURL: "", username: "user1@test.com", role: .writer)
            userRepo.stubbedSuggestedUsers = [mockSuggestedUser]
            
            // Act
            sut.email = "test@"
            
            try await Task.sleep(nanoseconds: 600_000_000)
            
            // Assert SHAR-004
            XCTAssertEqual(userRepo.searchEmailCallCount, 1)
            XCTAssertEqual(userRepo.receivedSearchEmail, "test@")
            XCTAssertEqual(sut.suggestedUsers.count, 1)
            XCTAssertEqual(sut.suggestedUsers.first?.id, "user-1")
            XCTAssertFalse(sut.isLoading)
        }

        @MainActor
        func test_searchByEmail_debouncesMultipleRapidChanges() async throws {
            // Arrange
            userRepo.stubbedSuggestedUsers = []
            
            // Act
            sut.email = "tes"
            sut.email = "test"
            sut.email = "test@"
            
            try await Task.sleep(nanoseconds: 600_000_000)
            
            // Assert
            XCTAssertEqual(userRepo.searchEmailCallCount, 1)
            XCTAssertEqual(userRepo.receivedSearchEmail, "test@")
        }
}
