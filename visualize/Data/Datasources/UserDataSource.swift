//
//  UserDataSource.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import FirebaseFirestore

class UserDataSource{
    
    private let firebase = Firestore.firestore()
    
    func getUser(id: UUID) async throws -> UserDTO {
        let document = try await firebase.collection("users").document(id.uuidString).getDocument()
        
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
    
}
