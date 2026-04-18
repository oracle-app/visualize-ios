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
    
    func getUserReference(userID: UUID) -> DocumentReference {
        let userRef = firebase.collection("users").document(userID.uuidString)
        return userRef
    }
    
    func groupsUserIsIn(userID: UUID) async throws -> [DocumentReference] {
        let userRef = getUserReference(userID: userID)
        let groupsReference = try await firebase.collection("groups")
            .whereField("membersID", arrayContains: userRef)
            .getDocuments()
        return groupsReference.documents.map {$0.reference}
    }
    
}
