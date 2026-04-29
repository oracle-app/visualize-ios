//
//  SignUpViewModel.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//

import Foundation
import Observation

// MARK: - Sign Up ViewModel

/// ViewModel responsible for managing the state and business interaction
/// of the Sign Up screen.
///
/// This class:
/// - Stores user input fields (name, email, password)
/// - Validates form state
/// - Manages UI state (loading, error messages)
/// - Coordinates the registration flow using `RegisterUseCase`
///
@Observable
class SignUpViewModel {
    
    // MARK: - Input State
    
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    
    // MARK: - UI State
    
    var errorMessage: String? = nil
    var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let registerUseCase: RegisterUseCase
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with its required use case.
    ///
    /// - Parameter registerUseCase: Use case responsible for user registration logic.
    init(registerUseCase: RegisterUseCase) {
        self.registerUseCase = registerUseCase
    }
    
    // MARK: - Computed Properties
    
    /// Indicates whether the sign-up form is valid for submission.
    ///
    /// - Returns: `true` if all fields are filled and passwords match.
    var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    // MARK: - Actions
    
    /// Executes the sign-up flow using the provided user input.
    ///
    /// This method:
    /// - Validates form state
    /// - Calls `RegisterUseCase`
    /// - Manages loading state
    /// - Handles errors from the registration process
    func signUp() {
        guard isFormValid else {
            errorMessage = "Please fill all fields correctly"
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let user = try await registerUseCase.execute(
                    email: email,
                    password: password,
                    username: name
                )
                
                print("Registered: \(user)")
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}
