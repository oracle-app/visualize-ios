//
//  UserRepository.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

protocol UserRepository {
    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser]
    
    /// Creates a new user in the system.
    ///
    /// This operation is part of the Domain Layer contract and is responsible for
    /// defining the creation of a user without exposing implementation details.
    ///
    /// - Parameter user: The domain user (`AppUser`) to be created.
    /// - Returns: The created user as a domain `AppUser`.
    /// - Throws: An error if the user creation process fails.
    func createUser(user: AppUser) async throws -> AppUser
    func addHiddenVisualization(userID: String, visualizationID: String) async throws
    func removeHiddenVisualization(userID: String, visualizationID: String) async throws
}
