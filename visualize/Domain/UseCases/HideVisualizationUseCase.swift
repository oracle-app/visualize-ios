//
//  HideVisualizationUseCase.swift
//  visualize
//
//  Created by Diana Escalante on 07/05/26.
//

/// Hides a visualization for the current user by adding it to their
/// hiddenVisualizations list and removing them from the visualization's sharedWithUsers.
class HideVisualizationUseCase {
    private let userRepository: any UserRepository
    private let visualizationRepository: any VisualizationRepository

    init(userRepository: any UserRepository, visualizationRepository: any VisualizationRepository) {
        self.userRepository = userRepository
        self.visualizationRepository = visualizationRepository
    }

    /// - Parameters:
    ///   - userID: The ID of the user hiding the visualization.
    ///   - visualizationID: The ID of the visualization to hide.
    func execute(userID: String, visualizationID: String) async throws {
        try await userRepository.addHiddenVisualization(userID: userID, visualizationID: visualizationID)
        try await visualizationRepository.removeUserFromSharedWith(visualizationID: visualizationID, userID: userID)
    }
}
