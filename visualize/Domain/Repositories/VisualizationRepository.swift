//
//  VisualizationRepository.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

/// Contract for visualization data operations.
import Foundation

protocol VisualizationRepository {
    /// Replaces `sharedWithUsers` and `sharedWithTeams` in a single atomic write.
    ///
    /// - Parameters:
    ///   - visualizationID: The ID of the visualization to update.
    ///   - userIDs: The new list of user IDs.
    ///   - teamIDs: The new list of team IDs.
    func updateSharing(visualizationID: String, userIDs: [String], teamIDs: [String]) async throws
    func getSharedVisualizations(userID: String) async throws -> [VisualizationCard]
    func getPersonalVisualizations(userID: String) async throws -> [VisualizationCard]
}
