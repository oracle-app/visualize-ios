//
//  AuthFirebaseDatasource.swift
//  visualize
//
//  Created by Libia Fv on 25/04/26.
//
import FirebaseAuth

class AuthFirebaseDatasource {
    
    // MARK: - Properties
    
    private let auth = Auth.auth()
    
    // MARK: - Authentication
    
    /// Signs in a user using email and password with Firebase Authentication.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: The authenticated Firebase user.
    /// - Throws: An error if the authentication process fails.
    func login(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user
    }
    
    /// Registers a new user using email and password with Firebase Authentication.
    ///
    /// - Parameters:
    ///   - email: The new user's email address.
    ///   - password: The new user's password.
    /// - Returns: The newly created Firebase user.
    /// - Throws:
    ///   - `RegisterError.emailAlreadyInUse` if the email is already registered.
    ///   - Any other Firebase Authentication error that occurs during registration.
    func register(email: String, password: String) async throws -> FirebaseAuth.User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return result.user
        } catch let error as NSError {
            if let authError = AuthErrorCode(rawValue: error.code),
               authError == .emailAlreadyInUse {
                throw RegisterError.emailAlreadyInUse
            }
            throw error
        }
    }
    
    /// Signs out the currently authenticated user.
    ///
    /// - Throws: An error if the sign-out process fails.
    func logout() throws {
        try auth.signOut()
    }
    
    // MARK: - Session
    
    /// Retrieves the currently authenticated user, if any.
    ///
    /// - Returns: The current Firebase user or `nil` if no user is signed in.
    func getCurrentUser() -> FirebaseAuth.User? {
        return auth.currentUser
    }
    
    /// Deletes the currently authenticated user from Firebase Authentication.
    ///
    /// This operation permanently removes the user account associated with
    /// the current session. After deletion, the user will no longer be
    /// authenticated and `auth.currentUser` will return `nil`.
    ///
    /// - Throws: An error if the deletion fails or if no user is currently signed in.
    func deleteCurrentUser() async throws {
        try await auth.currentUser?.delete()
    }
    
    /// Sends a password reset email to the given address.
    ///
    /// - Parameter email: The email address to send the reset link to.
    /// - Throws: An error if Firebase fails to send the email.
    func sendPasswordReset(to email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
}
