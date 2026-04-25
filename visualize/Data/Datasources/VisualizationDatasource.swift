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
    
    init(database: Firestore = Firestore.firestore(), userDatasource: UserDatasource) {
        self.firebase = database
        self.userDatasource = userDatasource
    }
    
    private func getVisualizationsSharedWithUser(userID: String) async throws -> [VisualizationDTO] {
        let sharedWithUser = try await firebase.collection("visualizations")
            .whereField("sharedWithUsers", arrayContains: userID)
            .getDocuments()
        return sharedWithUser.documents.compactMap {try? $0.data(as: VisualizationDTO.self)}
    }
    
    private func getVisualizationsSharedWithTeamsUserIsIn(userID: String) async throws -> [VisualizationDTO] {
        let userTeams = try await userDatasource.teamsUserIsIn(userID: userID)
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
                .whereField("authorID", isEqualTo: "/users/\(userID)")
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
}
