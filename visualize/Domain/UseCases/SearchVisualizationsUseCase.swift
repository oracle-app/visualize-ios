//
//  SearchVisualizationsUseCase.swift
//  visualize
//
//  Created by SOPORTE on 06/05/26.
//
class SearchVisualizationsUseCase {
    private let visualizationRepository: any VisualizationRepository
    
    init(visualizationRepository: any VisualizationRepository) {
        self.visualizationRepository = visualizationRepository
    }
    
    func execute(userID: String, query: String) async throws -> [VisualizationCard] {
        try await visualizationRepository.searchVisualizations(userID: userID, query: query)
    }
}
