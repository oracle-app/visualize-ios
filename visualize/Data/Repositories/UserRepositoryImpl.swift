//
//  UserRepositoryImpl.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

import UIKit

class UserRepositoryImpl: UserRepository {

    private let userDatasource: UserDatasource
    init(userDatasource: UserDatasource) {
        self.userDatasource = userDatasource
    }
    func getUserByID(userID: String) async throws -> AppUser {
        let userRaw: UserDTO = try await userDatasource.getUserByID(userID: userID)
        return userRaw.toAppUser()
    }

    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] {
        let usersRaw: [UserDTO] = try await userDatasource.getUserSuggestionsByEmail(email: email)
        return usersRaw.map { $0.toAppUser() }
    }
    
    func updateProfilePictureURL(userID: String, url: URL?) async throws {
        try await userDatasource.updateProfilePictureURL(userID: userID, url: url)
    }
    func deleteProfileImage(userID: String) async throws {
        try await userDatasource.deleteProfileImage(userID: userID)
    }
    
    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL {
        let url: URL = try await userDatasource.uploadProfileImage(
            userID: userID,
            imageData: imageData
        )
        return url
    }
    
    /// Creates a new user in the remote data source and returns the created user
    /// mapped into the domain model.
    ///
    /// This method:
    /// - Transforms the domain `AppUser` into a `UserDTO`
    /// - Sends it to the `UserDatasource` for persistence
    /// - Receives the stored user data
    /// - Maps it back into the domain model (`AppUser`)
    ///
    /// - Parameter user: The domain user to be created.
    /// - Returns: The created user as a domain `AppUser`.
    /// - Throws: An error if the user creation process fails.
    func createUser(user: AppUser) async throws -> AppUser {
        let uid = user.id
        let dto = UserDTO(
            id: uid,
            chartTheme: "",
            email: user.email,
            profilePictureURL: user.profilePictureURL ?? "",
            themePreference: "",
            userType: user.role.rawValue,
            username: user.username,
            hiddenVisualizations: []
        )
        let userRaw: UserDTO = try await userDatasource.createUser(
            user: dto,
            uid: user.id
        )
        return userRaw.toAppUser()
    }
    func addHiddenVisualization(userID: String, visualizationID: String) async throws {
        try await userDatasource.addHiddenVisualization(userID: userID, visualizationID: visualizationID)
    }
    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {
        try await userDatasource.removeHiddenVisualization(userID: userID, visualizationID: visualizationID)
    }
}
