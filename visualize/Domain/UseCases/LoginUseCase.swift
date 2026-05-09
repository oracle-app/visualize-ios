//
//  LoginUseCase.swift
//  visualize
//
//  Created by Libia Fv on 25/04/26.
//

import Foundation

// MARK: - Login Errors

/// Defines possible validation errors for the login process.
enum LoginError: Error {
    case emailRequired
    case invalidEmail
    case passwordRequired
}

// MARK: - Login Use Case

/// Use case responsible for handling the login business logic.
///
/// This layer:
/// - Validates user input (email and password)
/// - Applies business rules before authentication
/// - Delegates authentication to `AuthRepository`
///
/// It ensures that invalid data never reaches the repository layer.
class LoginUseCase {
    
    // MARK: - Properties
    
    private let repository: AuthRepository
    
    // MARK: - Initialization
    
    /// Initializes the use case with an authentication repository.
    ///
    /// - Parameter repository: The repository responsible for authentication operations.
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    // MARK: - Execution
    
    /// Executes the login process with validation and authentication.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: The authenticated user (`AuthUser`).
    /// - Throws: `LoginError` for validation issues or repository errors for authentication failures.
    func execute(email: String, password: String) async throws -> AuthUser {
        
        if email.isEmpty {
            throw LoginError.emailRequired
        }
        
        if !isValidEmail(email) {
            throw LoginError.invalidEmail
        }
        
        if password.isEmpty {
            throw LoginError.passwordRequired
        }
        
        return try await repository.login(email: email, password: password)
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
