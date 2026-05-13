//
//  RegisterUseCase.swift
//  visualize
//
//  Created by Libia Fv on 25/04/26.
//

import Foundation

// MARK: - Register Errors

/// Represents validation errors that can occur
/// during the user registration process.
///
/// These errors are thrown before attempting
/// authentication or user creation.
enum RegisterError: Error {
    case emailRequired
    case invalidEmail
    case passwordRequired
    case passwordTooShort
    case passwordNeedsLettersAndNumbers
    case passwordNeedsSpecialCharacter
    case emailAlreadyInUse
}

// MARK: - Register Use Case

/// Handles the business logic for registering a new user.
///
/// Responsibilities:
/// - Validate registration input data
/// - Create the authentication account
/// - Create the user document in the database
///
/// This use case acts as the bridge between
/// the presentation layer and repository layer.
class RegisterUseCase {
    
    // MARK: - Dependencies
    
    /// Repository responsible for authentication actions.
    private let authRepository: AuthRepository
    
    /// Repository responsible for user database operations.
    private let userRepository: UserRepository
    
    // MARK: - Initialization
    
    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Execute
    
    /// Registers a new user after validating all input fields.
    ///
    /// Steps:
    /// 1. Validate email and password requirements
    /// 2. Create authentication account
    /// 3. Create user profile object
    /// 4. Save user in database
    ///
    /// - Parameters:
    ///   - email: User email address
    ///   - password: User password
    ///   - username: Display name chosen by the user
    ///
    /// - Returns: The created `AppUser`
    ///
    /// - Throws:
    ///   - `RegisterError` when validation fails
    ///   - Repository errors during authentication or persistence
    func execute(email: String, password: String, username: String) async throws -> AppUser {
        
        // MARK: Input Validation
        
        if email.isEmpty {
            throw RegisterError.emailRequired
        }
        
        if !isValidEmail(email) {
            throw RegisterError.invalidEmail
        }
        
        if password.isEmpty {
            throw RegisterError.passwordRequired
        }
        
        if password.count < 12 {
            throw RegisterError.passwordTooShort
        }
        
        if !hasLettersAndNumbers(password) {
            throw RegisterError.passwordNeedsLettersAndNumbers
        }
        
        if !hasSpecialCharacter(password) {
            throw RegisterError.passwordNeedsSpecialCharacter
        }
        
        // MARK: Authentication
        
        let authUser = try await authRepository.register(
            email: email,
            password: password
        )
        
        // MARK: App User Creation
        
        let appUser = AppUser(
            id: authUser.uid,
            email: authUser.email,
            profilePictureURL: nil,
            username: username
        )
        
        // MARK: Database Persistence

        do {
            let savedUser = try await userRepository.createUser(user: appUser)
            return savedUser
        } catch {
            try? await authRepository.deleteCurrentUser()
            throw error
        }
    }
    
    // MARK: - Validation Helpers
    
    /// Validates email format using regex.
    ///
    /// - Parameter email: Email string to validate
    /// - Returns: `true` if email format is valid
    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^\S+@\S+\.\S+$"#
        
        return NSPredicate(
            format: "SELF MATCHES %@",
            regex
        ).evaluate(with: email)
    }
    
    /// Validates that the password contains
    /// at least one letter and one number.
    ///
    /// - Parameter password: Password string to validate
    /// - Returns: `true` if requirements are met
    private func hasLettersAndNumbers(_ password: String) -> Bool {
        let regex = #"^(?=.*[A-Za-z])(?=.*\d).*$"#
        
        return NSPredicate(
            format: "SELF MATCHES %@",
            regex
        ).evaluate(with: password)
    }
    
    /// Validates that the password contains
    /// at least one special character.
    ///
    /// Allowed characters:
    /// `$ @ $ ! % * # ? & .`
    ///
    /// - Parameter password: Password string to validate
    /// - Returns: `true` if requirements are met
    private func hasSpecialCharacter(_ password: String) -> Bool {
        let regex = #"^.*[$@$!%*#?&.].*$"#
        
        return NSPredicate(
            format: "SELF MATCHES %@",
            regex
        ).evaluate(with: password)
    }
}
