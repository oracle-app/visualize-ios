//
//  VisualizationRepository.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import Foundation

protocol VisualizationRepository {
    
    func getVisualizationsWithFilter(userID:UUID, visualizationFilter: VisualizationFilter) async throws -> [VisualizationCard]
}
