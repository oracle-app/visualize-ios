//
//  LoginViewModel.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//

import Foundation
import Observation

// MARK: - Login ViewModel

/// ViewModel responsible for managing the state and business interaction
/// of the Login screen.
///
/// This class:
/// - Stores user input (email, password)
/// - Manages UI state (loading, error messages)
/// - Validates form state
/// - Coordinates login flow through `LoginUseCase`
///
@Observable
class LoginViewModel {
    
    // MARK: - Input State
    
    var email = ""
    var password = ""
    
    // MARK: - UI State
    
    var errorMessage: String? = nil
    var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let loginUseCase: LoginUseCase
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with its required use case.
    ///
    /// - Parameter loginUseCase: Use case responsible for login business logic.
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    // MARK: - Computed Properties
    
    /// Indicates whether the login form is valid for submission.
    ///
    /// - Returns: `true` if both email and password are not empty.
    var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty
    }
    
    // MARK: - Actions
    
    /// Executes the login flow using the provided credentials.
    ///
    /// This method:
    /// - Validates form state
    /// - Calls `LoginUseCase`
    /// - Handles loading and error states
    /// - Prints user info on success (temporary debugging)
    func login() {
        guard isFormValid else {
            errorMessage = "Please fill all fields correctly"
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let user = try await loginUseCase.execute(
                    email: email,
                    password: password
                )
                
                print("UID: \(user.uid)")
                print("Login success: \(user)")
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}
