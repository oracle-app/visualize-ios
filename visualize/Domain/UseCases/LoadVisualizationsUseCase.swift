//
//  a.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import Foundation

struct LoadVisualizationsUseCase {
    let visualizationRepository: any VisualizationRepository
    func execute(userID: String, visualizationFilter: VisualizationFilter) async throws -> [VisualizationCard] {
        switch visualizationFilter {
        case .all:
            async let shared = visualizationRepository.getSharedVisualizations(userID: userID)
            async let personal = visualizationRepository.getPersonalVisualizations(userID: userID)
            return try await shared + personal
        case .shared:
            return try await visualizationRepository.getSharedVisualizations(userID: userID)
        case .personal:
            return try await visualizationRepository.getPersonalVisualizations(userID: userID)
        }
    }
}
