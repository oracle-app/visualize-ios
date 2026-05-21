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
        async let shared = visualizationRepository.getSharedVisualizations(userID: userID)
        async let personal = visualizationRepository.getPersonalVisualizations(userID: userID)
        return try await (shared + personal).sorted { $0.createdAt > $1.createdAt }
    }
}
