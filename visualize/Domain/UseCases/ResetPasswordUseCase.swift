//
//  ResetPasswordUseCase.swift
//  visualize
//
//  Created by Libia Fv on 12/05/26.
//

import Foundation

// MARK: - Reset Password Errors

/// Defines possible validation errors for the password reset process.
enum ResetPasswordError: Error {
    case emailRequired
    case invalidEmail
}

// MARK: - Reset Password Use Case

/// Use case responsible for handling the password reset business logic.
///
/// This layer:
/// - Validates user input (email)
/// - Applies business rules before sending the reset email
/// - Delegates the operation to `AuthRepository`
///
/// It ensures that invalid data never reaches the repository layer.
class ResetPasswordUseCase {

    // MARK: - Properties

    private let authRepository: AuthRepository

    // MARK: - Initialization

    /// Initializes the use case with an authentication repository.
    ///
    /// - Parameter repository: The repository responsible for authentication operations.
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    // MARK: - Execution

    /// Executes the password reset process with validation.
    ///
    /// - Parameter email: The user's email address.
    /// - Throws: `ResetPasswordError` for validation issues or repository errors for request failures.
    func execute(email: String) async throws {

        if email.isEmpty {
            throw ResetPasswordError.emailRequired
        }

        if !isValidEmail(email) {
            throw ResetPasswordError.invalidEmail
        }

        try await authRepository.sendPasswordReset(to: email)
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
