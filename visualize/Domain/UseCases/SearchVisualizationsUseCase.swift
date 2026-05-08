//
//  SearchVisualizationsUseCase.swift
//  visualize
//
//  Created by SOPORTE on 06/05/26.
//

/// Handles the logic for searching visualizations accessible to a user.
/// Delegates to the repository and returns matching results as `VisualizationCard` o
class SearchVisualizationsUseCase {
    private let visualizationRepository: any VisualizationRepository
    
    init(visualizationRepository: any VisualizationRepository) {
        self.visualizationRepository = visualizationRepository
    }
    
    /// Searches for visualizations by title across personal and shared content.
        /// - Parameters:
        ///   - userID: The ID of the user performing the search.
        ///   - query: The search string to match against visualization titles.
        /// - Returns: A list of `VisualizationCard` whose titles match the query.
    func execute(userID: String, query: String) async throws -> [VisualizationCard] {
        try await visualizationRepository.searchVisualizations(userID: userID, query: query)
    }
}
