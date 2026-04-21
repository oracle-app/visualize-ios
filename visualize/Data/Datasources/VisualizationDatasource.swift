//
//  VisualizationDatasource.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import FirebaseFirestore

class VisualizationDatasource {
    private let database = Firestore.firestore()
    private let userDatasource: UserDatasource
    
    init(userDatasource: UserDatasource) {
        self.userDatasource = userDatasource
    }
    
    private func getVisualizationsSharedWithUser(userID: String) async throws -> [VisualizationDTO] {
        let sharedWithUser = try await database.collection("visualizations")
            .whereField("sharedWithUsers", arrayContains: userID)
            .getDocuments()
        return sharedWithUser.documents.compactMap {try? $0.data(as: VisualizationDTO.self)}
    }
    
    private func getVisualizationsSharedWithGroupsUserIsIn(userID: String) async throws -> [VisualizationDTO] {
        let userGroups = try await userDatasource.groupsUserIsIn(userID: userID)
        let groupIDs = userGroups.compactMap {$0.id}
        guard !groupIDs.isEmpty else {return []}
        
        let sharedWithGroups = try await database.collection("visualizations")
            .whereField("sharedWithGroups", arrayContainsAny: groupIDs)
            .getDocuments()
        return sharedWithGroups.documents.compactMap {try? $0.data(as: VisualizationDTO.self)}
    }
    
    func getAllSharedVisualizations(userID:String) async throws -> [VisualizationDTO] {
        let sharedWithUser = try await getVisualizationsSharedWithUser(userID: userID)
        let sharedWithGroupsUserIsIn = try await getVisualizationsSharedWithGroupsUserIsIn(userID: userID)
        let sharedVisualizations = sharedWithUser + sharedWithGroupsUserIsIn
        
        var uniqueDict = [String: VisualizationDTO]()
        
        for dto in sharedVisualizations {
            if let id = dto.id {
                uniqueDict[id] = dto
            }
        }
        
        return Array(uniqueDict.values)
    }
    
    func getAllPersonalVisualizations(userID: UUID) async throws -> [VisualizationDTO] {
        let snapshot = try await database.collection("visualizations")
                .whereField("ownerID", isEqualTo: "/users/\(userID)")
                .getDocuments()
        let dtos = snapshot.documents.compactMap { document in
                    try? document.data(as: VisualizationDTO.self)
            }
        return dtos
    }
    
    func getAllUsersVisualizationIsSharedWith(visualizationID: String) async throws -> [UserDTO] {
        // 1. Obtener el documento de la visualización
        let vizRef = database.collection("visualizations").document(visualizationID)
        let snapshot = try await vizRef.getDocument()
        
        // 2. Mapear al DTO para obtener las referencias de los usuarios
        guard let vizDTO = try? snapshot.data(as: VisualizationDTO.self) else {
            throw NSError(domain: "VisualizationDataSource", code: 404, userInfo: [NSLocalizedDescriptionKey: "Visualización no encontrada"])
        }
        
        // 3. Descargar los datos de cada usuario en paralelo para mayor velocidad
        return try await withThrowingTaskGroup(of: UserDTO?.self) { group in
            for userRef in vizDTO.sharedWithUsers {
                group.addTask {
                    return try? await userRef.getDocument(as: UserDTO.self)
                }
            }
            
            var users: [UserDTO] = []
            for try await user in group {
                if let user = user {
                    users.append(user)
                }
            }
            return users
        }
    }
}
