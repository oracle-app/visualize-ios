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
            .getDocuments()
        return sharedWithTeams.documents.compactMap {try? $0.data(as: VisualizationDTO.self)}
    }
    func getAllSharedVisualizations(userID:String) async throws -> [VisualizationDTO] {
        let sharedWithUser = try await getVisualizationsSharedWithUser(userID: userID)
        let sharedWithTeamsUserIsIn = try await getVisualizationsSharedWithTeamsUserIsIn(userID: userID)
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
    /// Replaces the `sharedWithUsers` field of a visualization with the provided user IDs.
    /// - Parameters:
    ///   - visualizationID: The ID of the visualization to update.
    ///   - userIDs: The new list of user IDs to set as `sharedWithUsers`.
    func updateSharedUsers(visualizationID: String, userIDs: [String]) async throws {
        try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .updateData(["sharedWithUsers": userIDs])
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
}
