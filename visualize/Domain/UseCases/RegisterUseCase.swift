//
//  RegisterUseCase.swift
//  visualize
//
//  Created by Libia Fv on 25/04/26.
//

import Foundation

// MARK: - Register Errors

/// Defines possible validation errors for the registration process.
enum RegisterError: Error {
    case emailRequired
    case invalidEmail
    case passwordRequired
    case passwordTooShort
}

// MARK: - Register Use Case

/// Use case responsible for handling the user registration flow.
///
/// This use case coordinates:
/// - Input validation (email, password, username rules)
/// - Authentication account creation via `AuthRepository`
/// - Domain user creation via `UserRepository`
///
/// It ensures a complete and consistent user onboarding process across both
/// authentication and application data layers.
class RegisterUseCase {
    
    // MARK: - Properties
    
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    
    // MARK: - Initialization
    
    /// Initializes the use case with required repositories.
    ///
    /// - Parameters:
    ///   - authRepository: Repository responsible for authentication operations.
    ///   - userRepository: Repository responsible for user persistence.
    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Execution
    
    /// Executes the full user registration flow.
    ///
    /// This includes:
    /// 1. Validating input data
    /// 2. Creating authentication account
    /// 3. Building domain user model
    /// 4. Persisting user in the system database
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - username: The chosen username.
    /// - Returns: The created domain user (`AppUser`).
    /// - Throws: `RegisterError` for validation issues or repository errors for backend failures.
    func execute(email: String, password: String, username: String) async throws -> AppUser {
        
        if email.isEmpty {
            throw RegisterError.emailRequired
        }
        
        if !isValidEmail(email) {
            throw RegisterError.invalidEmail
        }
        
        if password.isEmpty {
            throw RegisterError.passwordRequired
        }
        
        if password.count < 6 {
            throw RegisterError.passwordTooShort
        }
        
        let authUser = try await authRepository.register(email: email, password: password)
        
        let appUser = AppUser(
            id: authUser.uid,
            email: authUser.email,
            profilePictureURL: nil,
            username: username
        )
        
        let savedUser = try await userRepository.createUser(user: appUser)
        
        return savedUser
    }
    
    // MARK: - Validation
    
    /// Validates if the provided email has a correct format.
    ///
    /// - Parameter email: The email string to validate.
    /// - Returns: `true` if the email format is valid, otherwise `false`.
    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^\S+@\S+\.\S+$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}
