//
//  VisualizationRepository.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

/// Contract for visualization data operations.
import Foundation

protocol VisualizationRepository {
    
    func getVisualizationsWithFilter(userID: String, visualizationFilter: VisualizationFilter) async throws -> [VisualizationCard]
    
    /// Replaces the shared users list of a visualization in Firestore.
    /// - Parameters:
    ///   - visualizationID: The ID of the visualization to update.
    ///   - userIDs: The new list of user IDs to set.
    func updateSharedUsers(visualizationID: String, userIDs: [String]) async throws
}
