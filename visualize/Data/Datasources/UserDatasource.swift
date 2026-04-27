//
//  UserDataSource.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import FirebaseFirestore

class UserDatasource{
    
    private let firebase: Firestore
    
    init(firebase: Firestore = Firestore.firestore()) {
        self.firebase = firebase
    }
    
    func getUserByID(userID: String) async throws -> UserDTO {
        let document = try await firebase.collection("users").document(userID).getDocument()
        
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
    
    func teamsUserIsIn(userID: String) async throws -> [TeamDTO] {
        let snapshot = try await firebase.collection("teams")
                .whereField("membersID", arrayContains: userID)
                .getDocuments()
            
        let teams = snapshot.documents.compactMap { document -> TeamDTO? in
            try? document.data(as: TeamDTO.self)
        }
        
        return teams
    }
    
    func getUserSuggestionsByEmail(email: String) async throws -> [UserDTO] {
        do {
            let snapshot = try await firebase.collection("users")
                    .whereField("email", isGreaterThanOrEqualTo: email)
                    .whereField("email", isLessThanOrEqualTo: email + "\u{f8ff}")
                    .limit(to: 5)
                    .getDocuments()
            return snapshot.documents.compactMap {document in
                    try? document.data(as: UserDTO.self)
            }
        } catch {
            throw error
        }
    }
    
}
