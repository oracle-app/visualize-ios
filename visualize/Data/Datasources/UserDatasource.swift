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
        do {
            let snapshot = try await firebase.collection("users")
                .document(userID)
                .getDocument()
            return try snapshot.data(as: UserDTO.self)
        } catch {
            throw error
        }
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
    /// Creates a new user document in Firestore.
    ///
    /// This method:
    /// - Persists the provided `UserDTO` into the "users" collection
    /// - Uses the provided `uid` as the document identifier
    /// - Returns the stored user with the assigned ID
    ///
    /// - Parameters:
    ///   - user: The data transfer object (`UserDTO`) to be stored.
    ///   - uid: The unique identifier used as the Firestore document ID.
    /// - Returns: The created `UserDTO` with the assigned ID.
    /// - Throws: An error if the write operation fails.
    func createUser(user: UserDTO, uid: String) async throws -> UserDTO {
        try firebase.collection("users").document(uid).setData(from: user)
        var newUser = user
        newUser.id = uid
        return newUser
    }
    func getUsers(byIDs ids: [String]) async throws -> [UserDTO] {
        guard !ids.isEmpty else { return [] }
        /// Firebase has a limit of 30. For testing purposes, we will assume no visualization will be shared with over 30 users.
        let snapshot = try await firebase.collection("users")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: UserDTO.self) }
    }
}
