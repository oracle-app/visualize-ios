//
//  ResetPasswordViewModel.swift
//  visualize
//
//  Created by Mariana Islas Mondragón on 05/05/26.
//

import Foundation
import Observation
import FirebaseAuth

// MARK: - Reset Password ViewModel

/// ViewModel responsible for managing the state and business interaction
/// of the Reset Password screen.
///
/// This class:
/// - Stores user input (email)
/// - Validates form state inline while editing
/// - Manages UI state (loading, error messages)
/// - Coordinates the password reset flow through `ResetPasswordUseCase`
///
@MainActor
@Observable
class ResetPasswordViewModel {

    // MARK: - Input State

    /// Email entered by the user for password recovery.
    ///
    /// Revalidates automatically while editing after an error appears.
    var email = "" {
        didSet {
            if emailError != nil {
                _ = validateEmail()
            }
        }
    }

    // MARK: - UI State

    /// Validation error for the email field.
    var emailError: String? = nil

    /// Generic error message for unexpected failures.
    var errorMessage: String? = nil

    /// Indicates whether a request is in progress.
    var isLoading: Bool = false

    /// Set to `true` once the reset email is sent successfully.
    /// Triggers the success state in the view.
    var didSendEmail: Bool = false

    // MARK: - Dependencies

    private let resetPasswordUseCase: ResetPasswordUseCase

    // MARK: - Initialization

    init(resetPasswordUseCase: ResetPasswordUseCase) {
        self.resetPasswordUseCase = resetPasswordUseCase
    }

    // MARK: - Actions

    /// Validates the email field and triggers the password reset request.
    func submit() {
        guard !isLoading else { return }
        errorMessage = nil
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard validateEmail() else { return }

        Task {
            isLoading = true

            do {
                try await resetPasswordUseCase.execute(email: email)
                didSendEmail = true

            } catch let error as ResetPasswordError {
                switch error {
                case .emailRequired:
                    self.emailError = "Required fields cannot be left blank."
                case .invalidEmail:
                    self.emailError = "Please enter a valid email address."
                }

            } catch let error as NSError {
                if let authError = AuthErrorCode(rawValue: error.code),
                   authError == .userNotFound {
                    didSendEmail = true
                } else {
                    self.errorMessage = "Something went wrong. Please try again."
                }
            }

            isLoading = false
        }
    }

    // MARK: - Validation

    /// Validates the email field.
    ///
    /// Rules:
    /// - Cannot be empty
    /// - Must match a valid email format
    ///
    /// - Returns: `true` if valid, otherwise `false`.
    private func validateEmail() -> Bool {

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = "Required fields cannot be left blank."
            return false
        }

        let regex = #"^\S+@\S+\.\S+$"#

        if !NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email) {

            emailError = "Please enter a valid email address."
            return false
        }

        emailError = nil
        return true
    }
}
