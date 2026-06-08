//
//  CreateVisualizationUseCaseTests.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 07/06/26.
//
//  Unit tests for the Generate Visualization persistence flow:
//  - GENV-007: Create visualization with title and chart configuration
//

import XCTest
@testable import visualize

// MARK: - Mocks

private final class GenTestsMockVisualizationRepository: VisualizationRepository {
    var createVisualizationCallCount = 0
    var receivedTitle: String?
    var receivedAuthorID: String?
    var receivedConfigJSON: String?
    var receivedPreviewJSON: String?
    var receivedUserIDs: [String]?
    var receivedTeamIDs: [String]?
    var stubbedError: Error?

    func createVisualization(
        title: String,
        authorID: String,
        configJSON: String,
        previewJSON: String,
        userIDs: [String],
        teamIDs: [String]
    ) async throws {
        createVisualizationCallCount += 1
        receivedTitle = title
        receivedAuthorID = authorID
        receivedConfigJSON = configJSON
        receivedPreviewJSON = previewJSON
        receivedUserIDs = userIDs
        receivedTeamIDs = teamIDs

        if let stubbedError {
            throw stubbedError
        }
    }

    // Unused in these tests — stubbed to satisfy the protocol.
    func updateSharing(visualizationID: String, userIDs: [String], teamIDs: [String]) async throws {}
    func getAllVisualizations(userID: String) async throws -> [VisualizationCard] { [] }
    func searchVisualizations(userID: String, query: String) async throws -> [VisualizationCard] { [] }
    func deleteVisualization(visualizationID: String) async throws {}
    func removeUserFromSharedWith(visualizationID: String, userID: String) async throws {}
    func fetchConfigJSON(visualizationID: String) async throws -> String? { nil }
}

private struct DummyVisualizationRepositoryError: Error, Equatable {}

// MARK: - Tests

final class CreateVisualizationUseCaseTests: XCTestCase {

    // MARK: - Helpers

    /// Creates a domain user used to verify mapping from AppUser to user ID.
    /// - Parameter id: User identifier.
    /// - Returns: A test AppUser.
    private func makeUser(id: String) -> AppUser {
        AppUser(
            id: id,
            email: "\(id)@example.com",
            profilePictureURL: nil,
            username: id,
            role: .writer
        )
    }

    // MARK: - GENV-007

    // GENV-007 — CreateVisualizationUseCase forwards chart data and sharing configuration to repository.
    func test_execute_createsVisualizationWithTitleAndConfiguration() async throws {
        let repository = GenTestsMockVisualizationRepository()
        let sut = CreateVisualizationUseCase(visualizationRepository: repository)

        try await sut.execute(
            title: "Survival Rate by Passenger Class",
            authorID: "author-123",
            configJSON: "{\"chartType\":\"Vertical Bar Chart\"}",
            previewJSON: "{\"chartType\":\"Vertical Bar Chart\",\"preview\":true}",
            users: [makeUser(id: "user-1"), makeUser(id: "user-2")],
            teamIDs: ["team-1", "team-2"]
        )

        XCTAssertEqual(repository.createVisualizationCallCount, 1)
        XCTAssertEqual(repository.receivedTitle, "Survival Rate by Passenger Class")
        XCTAssertEqual(repository.receivedAuthorID, "author-123")
        XCTAssertEqual(repository.receivedConfigJSON, "{\"chartType\":\"Vertical Bar Chart\"}")
        XCTAssertEqual(repository.receivedPreviewJSON, "{\"chartType\":\"Vertical Bar Chart\",\"preview\":true}")
        XCTAssertEqual(repository.receivedUserIDs, ["user-1", "user-2"])
        XCTAssertEqual(repository.receivedTeamIDs, ["team-1", "team-2"])
    }

    // Repository errors should propagate so the UI can show a failure state.
    func test_execute_whenRepositoryThrows_propagatesError() async {
        let repository = GenTestsMockVisualizationRepository()
        repository.stubbedError = DummyVisualizationRepositoryError()
        let sut = CreateVisualizationUseCase(visualizationRepository: repository)

        do {
            try await sut.execute(
                title: "Failed Chart",
                authorID: "author-123",
                configJSON: "{}",
                previewJSON: "{}",
                users: [],
                teamIDs: []
            )
            XCTFail("Expected repository error to propagate")
        } catch is DummyVisualizationRepositoryError {
            XCTAssertEqual(repository.createVisualizationCallCount, 1)
        } catch {
            XCTFail("Expected DummyVisualizationRepositoryError, got \(error)")
        }
    }
}
