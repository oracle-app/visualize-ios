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
    
    func getAllVisualizations(userID: String) async throws -> [VisualizationCard]
    func searchVisualizations(userID: String, query: String) async throws -> [VisualizationCard]

    func deleteVisualization(visualizationID: String) async throws
    func removeUserFromSharedWith(visualizationID: String, userID: String) async throws

    /// Creates a new visualization and persists it to the data store.
    ///
    /// - Parameters:
    ///   - title: Display title chosen by the user.
    ///   - authorID: ID of the user creating the visualization.
    ///   - configJSON: Full chart JSON for `FullScreenView` rendering.
    ///   - previewJSON: Reduced chart JSON for feed card previews.
    ///   - userIDs: IDs of users the visualization is shared with.
    ///   - teamIDs: IDs of teams the visualization is shared with.
    func createVisualization(
        title: String,
        authorID: String,
        configJSON: String,
        previewJSON: String,
        userIDs: [String],
        teamIDs: [String]
    ) async throws
 
    /// Fetches only the `configJSON` field for a single visualization from the data store.
    /// Used by `FullScreenView` to load the full chart data on demand, avoiding the
    /// memory cost of carrying `configJSON` in every feed card.
    /// - Parameter visualizationID: The ID of the visualization to fetch.
    /// - Returns: The raw `configJSON` string, or `nil` if the document or field is missing.
    func fetchConfigJSON(visualizationID: String) async throws -> String?
}
