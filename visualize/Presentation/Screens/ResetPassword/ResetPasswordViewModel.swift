//
//  ResetPasswordViewModel.swift
//  visualize
//
//  Created by Mariana Islas Mondragón on 05/05/26.
//

import Foundation
import Observation

// MARK: - Reset Password ViewModel

/// ViewModel responsible for managing the state and user interaction
/// of the Reset Password screen.
///
/// This class:
/// - Stores user input (email)
/// - Validates form state
/// - Manages UI state (loading, error messages)
/// - Will coordinate the password reset flow (e.g. sending recovery email)
///
@Observable
class ResetPasswordViewModel {
    
    // MARK: - Input State
    
    /// Email entered by the user for password recovery
    var email = ""
    
    // MARK: - UI State
    
    /// Error message to display if something goes wrong
    var errorMessage: String? = nil
    
    
    /// Indicates whether a request is in progress
    var isLoading: Bool = false
    
    // MARK: - Computed Properties
    
    /// Indicates whether the reset-password form is valid for submission.
    ///
    /// - Returns: `true` if the email field is not empty.
    var isFormValid: Bool {
        !email.isEmpty
    }
}
