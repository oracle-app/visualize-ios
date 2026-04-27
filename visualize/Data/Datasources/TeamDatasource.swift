//
//  TeamsDatasource.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

import FirebaseFirestore

final class TeamDatasource {
    private let firebase: Firestore
    
    init(firebase: Firestore = Firestore.firestore()) {
        self.firebase = firebase
    }
    
    func getTeamsUserOwns(userID: String) async throws -> [TeamDTO] {
        
        do {
            let snapshot = try await firebase.collection("teams")
                .whereField("ownerID" , isEqualTo: userID)
                .getDocuments()
            if snapshot.isEmpty {
                return []
            }
            
            return snapshot.documents.compactMap { document in
                try? document.data(as: TeamDTO.self)
            }
        } catch {
            throw error
        }
    }
    
    func getTeamsUserIsIn(userID: String) async throws -> [TeamDTO] {
        do{
            let snapshot = try await firebase.collection("teams")
                .whereField("membersIDs", arrayContains: userID)
                .getDocuments()
            
            if snapshot.isEmpty {
                return []
            }
            
            return snapshot.documents.compactMap { document in
                try? document.data(as: TeamDTO.self)
            }

        } catch {
            throw error
        }
            
    }
    
}
