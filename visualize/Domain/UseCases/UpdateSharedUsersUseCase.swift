//
//  UpdateSharedUsersUseCase.swift
//  visualize
//
//  Created by Diana Escalante on 29/04/26.
//

/// Handles updating both sharedWithUsers and sharedWithTeams of a visualization
/// in a single atomic Firestore write.
class UpdateSharingUseCase {

    private let visualizationRepository: any VisualizationRepository

    init(visualizationRepository: any VisualizationRepository) {
        self.visualizationRepository = visualizationRepository
    }

    /// Replaces sharedWithUsers and sharedWithTeams in Firestore.
    /// - Parameters:
    ///   - visualizationID: The ID of the visualization to update.
    ///   - users: The new list of AppUser to share with.
    ///   - teamIDs: The new list of team IDs to share with.
    /// - Returns: The same users and teamIDs, to apply locally after a successful write.
    func execute(
        visualizationID: String,
        users: [AppUser],
        teamIDs: [String]
    ) async throws -> (users: [AppUser], teamIDs: [String]) {
        try await visualizationRepository.updateSharing(
            visualizationID: visualizationID,
            userIDs: users.map { $0.id },
            teamIDs: teamIDs
        )
        return (users, teamIDs)
    }
}
