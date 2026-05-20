//
//  VisualizationDatasource.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import FirebaseFirestore

class VisualizationDatasource {
    private let firebase: Firestore
    private let userDatasource: UserDatasource
    private let teamsDatasource: TeamDatasource
    init(database: Firestore = Firestore.firestore(), userDatasource: UserDatasource, teamsDatasource: TeamDatasource) {
        self.firebase = database
        self.userDatasource = userDatasource
        self.teamsDatasource = teamsDatasource
    }
    
    private func getVisualizationsSharedWithUser(userID: String) async throws -> [VisualizationDTO] {
        let sharedWithUser = try await firebase.collection("visualizations")
            .whereField("sharedWithUsers", arrayContains: userID)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return sharedWithUser.documents.compactMap {
            do {
                return try $0.data(as: VisualizationDTO.self)
            } catch {
                print("Decoding error:", error)
                return nil
            }
        }
    }
    
    private func getVisualizationsSharedWithTeamsUserIsIn(userID: String) async throws -> [VisualizationDTO] {
        let userTeams = try await teamsDatasource.getTeamsUserIsIn(userID: userID)
        let teamIDs = userTeams.compactMap {$0.id}
        guard !teamIDs.isEmpty else {return []}
        let sharedWithTeams = try await firebase.collection("visualizations")
            .whereField("sharedWithTeams", arrayContainsAny: teamIDs)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return sharedWithTeams.documents.compactMap {try? $0.data(as: VisualizationDTO.self)}
    }
    
    func getAllSharedVisualizations(userID: String) async throws -> [VisualizationDTO] {
        async let sharedWithUserTask = getVisualizationsSharedWithUser(userID: userID)
        async let sharedWithTeamsTask = getVisualizationsSharedWithTeamsUserIsIn(userID: userID)
        let (sharedWithUser, sharedWithTeamsUserIsIn) = try await (sharedWithUserTask, sharedWithTeamsTask)
        let sharedVisualizations = sharedWithUser + sharedWithTeamsUserIsIn
        var uniqueDict = [String: VisualizationDTO]()
        for dto in sharedVisualizations {
            if let id = dto.id {
                uniqueDict[id] = dto
            }
        }
        return Array(uniqueDict.values)
    }
    
    func getAllPersonalVisualizations(userID: String) async throws -> [VisualizationDTO] {
        let snapshot = try await firebase.collection("visualizations")
            .whereField("authorID", isEqualTo: "\(userID)")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        let dtos = snapshot.documents.compactMap { document in
            try? document.data(as: VisualizationDTO.self)
        }
        return dtos
    }
    
    func getAllUsersVisualizationIsSharedWith(visualizationID: String) async throws -> [UserDTO] {
        let vizRef = firebase.collection("visualizations").document(visualizationID)
        let snapshot = try await vizRef.getDocument()
        guard let vizDTO = try? snapshot.data(as: VisualizationDTO.self) else {
            throw NSError(domain: "VisualizationDataSource", code: 404, userInfo: [NSLocalizedDescriptionKey: "Visualización no encontrada"])
        }
        var users: [UserDTO] = []
        for userID in vizDTO.sharedWithUsers {
            let userRef = firebase.collection("users").document(userID)
            if let user = try? await userRef.getDocument(as: UserDTO.self) {
                users.append(user)
            }
        }
        return users
    }
    /// Replaces both `sharedWithUsers` and `sharedWithTeams` in a single Firestore write.
    ///
    /// - Parameters:
    ///   - visualizationID: The ID of the visualization to update.
    ///   - userIDs: The new list of user IDs to set.
    ///   - teamIDs: The new list of team IDs to set.
    func updateSharing(visualizationID: String, userIDs: [String], teamIDs: [String]) async throws {
        try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .updateData([
                "sharedWithUsers": userIDs,
                "sharedWithTeams": teamIDs
            ])
    }
    
    /// Searches visualizations accessible to a user (personal + shared) by title.
    /// Filters client-side since Firestore does not support native full-text search.
    /// - Parameters:
    ///   - userID: The ID of the user performing the search.
    ///   - query: The search string to match against visualization titles.
    func searchVisualizations(userID: String, query: String) async throws -> [VisualizationDTO] {
        let lowercased = query.lowercased()
        
        let personal = try await getAllPersonalVisualizations(userID: userID)
        let shared = try await getAllSharedVisualizations(userID: userID)
        
        let all = personal + shared
        var uniqueDict = [String: VisualizationDTO]()
        for dto in all {
            if let id = dto.id { uniqueDict[id] = dto }
        }
        
        return Array(uniqueDict.values).filter {
            $0.title.lowercased().contains(lowercased)
        }
    }
    
    func deleteVisualization(visualizationID: String) async throws {
        try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .delete()
    }
    
    func removeUserFromSharedWith(visualizationID: String, userID: String) async throws {
        try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .updateData([
                "sharedWithUsers": FieldValue.arrayRemove([userID])
            ])
    }
    
    /// Creates a new visualization document in Firestore with config and preview JSON fields.
    ///
    /// - Parameters:
    ///   - title: Display title chosen by the user.
    ///   - authorID: ID of the user creating the visualization.
    ///   - configJSON: Full chart JSON for `FullScreenView` rendering.
    ///   - previewJSON: Reduced chart JSON for feed card previews.
    ///   - userIDs: IDs of users the visualization is shared with. Empty for personal feed.
    ///   - teamIDs: IDs of teams the visualization is shared with. Empty for personal feed.
    /// - Throws: Any Firestore write error.
    func createVisualization(
        title: String,
        authorID: String,
        configJSON: String,
        previewJSON: String,
        userIDs: [String],
        teamIDs: [String]
    ) async throws {
        let dto = VisualizationDTO(
            title: title,
            sharedWithTeams: teamIDs,
            sharedWithUsers: userIDs,
            createdAt: Date(),
            authorID: authorID,
            configJSON: configJSON,
            previewJSON: previewJSON
        )
        try firebase.collection("visualizations").addDocument(from: dto)
    }
    
    /// Fetches only the `configJSON` field for a single visualization.
    /// Called by `FullScreenView` on demand to avoid loading the full JSON into every
    /// feed card. Returns `nil` if the document does not exist or the field is missing.
    /// - Parameter visualizationID: The Firestore document ID of the visualization.
    /// - Returns: The raw `configJSON` string, or `nil` if unavailable.
    /// - Throws: Any Firestore read error.
    func fetchConfigJSON(visualizationID: String) async throws -> String? {
        let snapshot = try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .getDocument()
        return snapshot.data()?["configJSON"] as? String
    }
}
