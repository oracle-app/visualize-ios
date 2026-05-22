//
//  a.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import Foundation

struct LoadVisualizationsUseCase {
    let visualizationRepository: any VisualizationRepository
    func execute(userID: String) async throws -> [VisualizationCard] {
        return try await visualizationRepository.getAllVisualizations(userID: userID)
    }
}
