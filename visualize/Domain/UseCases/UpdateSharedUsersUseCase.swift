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
    private let userRepository: any UserRepository

    init(visualizationRepository: any VisualizationRepository, userRepository: any UserRepository) {
        self.visualizationRepository = visualizationRepository
        self.userRepository = userRepository
    }

    /// Replaces `sharedWithUsers` and `sharedWithTeams` in Firestore with the provided
    /// users and teams, then returns them to apply locally.
    ///
    /// - Parameters:
    ///   - visualizationID: The ID of the visualization to update.
    ///   - users: The new list of `AppUser` to share with.
    ///   - teamIDs: The new list of team IDs to share with.
    /// - Returns: A tuple with the confirmed users and teamIDs.
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
        for user in users {
            try await userRepository.removeHiddenVisualization(userID: user.id, visualizationID: visualizationID)
        }
        return (users, teamIDs)
    }
}
