//
//  AuthRepositoryImpl.swift
//  visualize
//
//  Created by Libia Fv on 25/04/26.
//

// MARK: - Auth Repository Implementation

/// Concrete implementation of `AuthRepository` that acts as a bridge between
/// the domain layer and the Firebase data source.
///
/// This class is responsible for:
/// - Delegating authentication operations to `AuthFirebaseDatasource`
/// - Mapping Firebase models into domain models (`AuthUser`)
/// - Keeping the domain layer independent from Firebase SDK
class AuthRepositoryImpl: AuthRepository {
    
    // MARK: - Properties
    
    private let source: AuthFirebaseDatasource
    
    // MARK: - Initialization
    
    /// Initializes the repository with a Firebase authentication data source.
    ///
    /// - Parameter source: The Firebase-based data source used for authentication.
    init(source: AuthFirebaseDatasource) {
        self.source = source
    }
    
    // MARK: - Authentication
    
    /// Logs in a user using email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: A domain `AuthUser` representing the authenticated user.
    /// - Throws: An error if the login process fails.
    func login(email: String, password: String) async throws -> AuthUser {
        let firebaseUser = try await source.login(email: email, password: password)
        return firebaseUser.toDomain()
    }
    
    /// Registers a new user using email and password.
    ///
    /// - Parameters:
    ///   - email: The new user's email address.
    ///   - password: The new user's password.
    /// - Returns: A domain `AuthUser` representing the created user.
    /// - Throws: An error if the registration process fails.
    func register(email: String, password: String) async throws -> AuthUser {
        let firebaseUser = try await source.register(email: email, password: password)
        return firebaseUser.toDomain()
    }
    
    /// Logs out the currently authenticated user.
    ///
    /// - Throws: An error if the logout process fails.
    func logout() throws {
        try source.logout()
    }
    
    /// Retrieves the currently authenticated user, if any.
    ///
    /// - Returns: A domain `AuthUser` or `nil` if no user is signed in.
    func getCurrentUser() -> AuthUser? {
        return source.getCurrentUser()?.toDomain()
    }
    
    /// Deletes the currently authenticated user account.
    ///
    /// This operation permanently removes the user from the authentication system.
    /// After successful deletion, the current session becomes invalid and the user
    /// will no longer be signed in.
    ///
    ///
    /// - Throws: An error if the deletion fails or if there is no authenticated user.
    func deleteCurrentUser() async throws {
        try await source.deleteCurrentUser()
    }
}
