//
//  DeleteVisualizationUseCase.swift
//  visualize
//
//  Created by Diana Escalante on 07/05/26.
//

/// Permanently deletes a visualization for all users.
struct DeleteVisualizationUseCase {
    private let visualizationRepository: any VisualizationRepository

    init(visualizationRepository: any VisualizationRepository) {
        self.visualizationRepository = visualizationRepository
    }

    /// - Parameter visualizationID: The ID of the visualization to delete.
    func execute(visualizationID: String) async throws {
        try await visualizationRepository.deleteVisualization(visualizationID: visualizationID)
    }
}
