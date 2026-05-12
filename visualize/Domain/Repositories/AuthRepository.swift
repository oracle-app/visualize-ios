//
//  AuthRepository.swift
//  visualize
//
//  Created by Libia Fv on 25/04/26.
//

// MARK: - Authentication Repository Protocol

/// Protocol that defines the authentication contract for the application.
///
/// This abstraction allows the app to remain independent of the underlying
/// authentication implementation (e.g., Firebase, mock services, etc.).
///
/// It is part of the Domain Layer and is used by UseCases or ViewModels
/// to perform authentication-related operations without knowing implementation details.
protocol AuthRepository {
    // MARK: - Authentication
    
    /// Authenticates a user using email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: The authenticated domain user (`AuthUser`).
    /// - Throws: An error if authentication fails.
    func login(email: String, password: String) async throws -> AuthUser
    
    /// Registers a new user using email and password.
    ///
    /// - Parameters:
    ///   - email: The email address for the new user.
    ///   - password: The password for the new user.
    /// - Returns: The created domain user (`AuthUser`).
    /// - Throws: An error if registration fails.
    func register(email: String, password: String) async throws -> AuthUser
    
    /// Logs out the currently authenticated user.
    ///
    /// - Throws: An error if logout fails.
    func logout() throws
    
    /// Retrieves the currently authenticated user, if any.
    ///
    /// - Returns: The current domain user or `nil` if no session exists.
    func getCurrentUser() -> AuthUser?
    
    /// Deletes the currently authenticated user.
    func deleteCurrentUser() async throws
}
