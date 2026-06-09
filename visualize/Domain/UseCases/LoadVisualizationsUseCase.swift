//
//  a.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import Foundation

class LoadVisualizationsUseCase {
    let visualizationRepository: any VisualizationRepository
    
    init(visualizationRepository: any VisualizationRepository) {
        self.visualizationRepository = visualizationRepository
    }
    
    func execute(userID: String) async throws -> [VisualizationCard] {
        return try await visualizationRepository.getAllVisualizations(userID: userID)
    }
}
