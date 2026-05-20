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
                .whereField("ownerID",isEqualTo: userID)
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
        do {
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
    
    func createTeam(newTeam: TeamDTO) async throws {
        do {
            try firebase.collection("teams").addDocument(from: newTeam)
        } catch {
            throw error
        }
    }
    
    func deleteTeam(teamID: String) async throws {
        do {
            try await firebase.collection("teams").document(teamID).delete()
        } catch {
            throw error
        }
    }
    
    func getTeams(byIDs ids: [String]) async throws -> [TeamDTO] {
        guard !ids.isEmpty else { return [] }
        /// Firebase has a limit of 30. For testing purposes,
        /// we will assume no visualization will be shared with over 30 users.
        let snapshot = try await firebase.collection("teams")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: TeamDTO.self) }
    }
}
