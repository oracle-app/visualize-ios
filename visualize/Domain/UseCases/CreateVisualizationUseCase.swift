//
//  CreateVisualizationUseCase.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 10/05/26.
//

/// Persists a new visualization to the data store with its sharing configuration.
/// This use case:
/// - Maps selected `AppUser` domain objects to plain user ID strings
/// - Delegates creation to the visualization repository with config and preview JSON
struct CreateVisualizationUseCase {
 
    // MARK: - Dependencies
 
    private let visualizationRepository: any VisualizationRepository
 
    // MARK: - Init
 
    /// - Parameter visualizationRepository: Repository responsible for persisting visualizations.
    init(visualizationRepository: any VisualizationRepository) {
        self.visualizationRepository = visualizationRepository
    }
 
    // MARK: - Execute
 
    /// Creates a new visualization and saves it with the given sharing configuration.
    /// - Parameters:
    ///   - title: User-facing title for the visualization.
    ///   - authorID: ID of the user creating the visualization.
    ///   - configJSON: Full JSON string used by `FullScreenView` to render the chart.
    ///   - previewJSON: Reduced JSON string used for feed card previews.
    ///   - users: Domain users the visualization is shared with.
    ///   - teamIDs: IDs of teams the visualization is shared with.
    /// - Throws: Any error propagated by the repository.
    func execute(
        title: String,
        authorID: String,
        configJSON: String,
        previewJSON: String,
        users: [AppUser],
        teamIDs: [String]
    ) async throws {
        let userIDs: [String] = users.map { $0.id }
        try await visualizationRepository.createVisualization(
            title: title,
            authorID: authorID,
            configJSON: configJSON,
            previewJSON: previewJSON,
            userIDs: userIDs,
            teamIDs: teamIDs
        )
    }
}
