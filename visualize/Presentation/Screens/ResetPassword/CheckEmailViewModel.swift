//
//  CheckEmailViewModel.swift
//  visualize
//
//  Created by Libia Fv on 12/05/26.
//

import Foundation
import Observation

// MARK: - Check Email ViewModel

/// ViewModel responsible for managing the state and business interaction
/// of the Check Email screen.
///
/// This class:
/// - Stores the email the reset link was sent to
/// - Handles the resend email flow
/// - Manages UI state (loading, resend confirmation)
///
@MainActor
@Observable
class CheckEmailViewModel {

    // MARK: - Properties

    /// Email the reset link was sent to.
    let email: String

    // MARK: - UI State

    /// Indicates whether a resend request is in progress.
    var isResending: Bool = false

    /// Set to `true` once the resend completes, to show confirmation to the user.
    var didResend: Bool = false

    // MARK: - Dependencies

    private let resetPasswordUseCase: ResetPasswordUseCase

    // MARK: - Initialization

    init(email: String, resetPasswordUseCase: ResetPasswordUseCase) {
        self.email = email
        self.resetPasswordUseCase = resetPasswordUseCase
    }

    // MARK: - Actions

    /// Resends the password reset email.
    func resend() {
        Task {
            isResending = true
            defer { isResending = false }

            do {
                try await resetPasswordUseCase.execute(email: email)
                didResend = true
            } catch {
                // Firebase does not distinguish between registered and unregistered
                // emails for security reasons, so the success state is always shown.
                didResend = true
            }
        }
    }
}
