//
//  UserDataSource.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import FirebaseFirestore

class UserDatasource{
    
    private let firebase = Firestore.firestore()
    
    func getUser(id: String) async throws -> UserDTO {
        let document = try await firebase.collection("users").document(id).getDocument()
        
        guard document.exists else {
                    throw NSError(domain: "UserDataSource", code: 404, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado"])
                }
        do {
            let userDto = try document.data(as: UserDTO.self)
            return userDto
        } catch {
            print("Error al parsear UserDTO: \(error)")
            throw error
        }
    }
    
    func groupsUserIsIn(userID: String) async throws -> [GroupDTO] {
        let snapshot = try await firebase.collection("groups")
                .whereField("membersID", arrayContains: userID)
                .getDocuments()
            
        let groups = snapshot.documents.compactMap { document -> GroupDTO? in
            try? document.data(as: GroupDTO.self)
        }
        
        return groups
    }
    
}
