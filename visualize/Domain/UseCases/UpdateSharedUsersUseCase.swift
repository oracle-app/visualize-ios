//
//  UpdateSharedUsersUseCase.swift
//  visualize
//
//  Created by Diana Escalante on 29/04/26.
//

/// Handles the logic for updating the shared users of a visualization.
/// Persists the change to Firestore and returns the updated local list.
class UpdateSharedUsersUseCase {

    private let visualizationRepository: any VisualizationRepository

    init(visualizationRepository: any VisualizationRepository) {
        self.visualizationRepository = visualizationRepository
    }

    /// Replaces `sharedWithUsers` in Firestore with the provided users and returns them.
    /// - Parameters:
    ///   - visualizationID: The ID of the visualization to update.
    ///   - users: The new list of `AppUser` to share the visualization with.
    /// - Returns: The same `users` array, to be applied locally after a successful write.
    func execute(visualizationID: String, users: [AppUser]) async throws -> [AppUser] {
        let userIDs = users.map { $0.id }
        try await visualizationRepository.updateSharedUsers(
            visualizationID: visualizationID,
            userIDs: userIDs
        )
        return users
    }
}
