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
    
    var email = "" {
        didSet {
            if emailError != nil {
                _ = validateEmail()
            }
        }
    }
    
    var password = "" {
        didSet {
            if passwordError != nil {
                _ = validatePassword()
            }
        }
    }
    
    // MARK: - UI Error State
    
    var emailError: String? = nil
    var passwordError: String? = nil
    var errorMessage: String? = nil
    var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let loginUseCase: LoginUseCase
    
    // MARK: - Initialization
    
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    // MARK: - Actions
    
    func login() {
        errorMessage = nil
        
        let isEmailValid = validateEmail()
        let isPasswordValid = validatePassword()
        
        guard isEmailValid && isPasswordValid else { return }
        
        Task {
            isLoading = true
            
            do {
                let user = try await loginUseCase.execute(
                    email: email,
                    password: password
                )
                
                print("Login success: \(user)")
                
            } catch let error as LoginError {
                switch error {
                case .emailRequired, .invalidEmail:
                    self.emailError = "Please enter a valid email address."
                case .passwordRequired:
                    self.passwordError = "Required fields cannot be left blank."
                }
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Validation
    
    private func validateEmail() -> Bool {
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = "Required fields cannot be left blank."
            return false
        }
        
        emailError = nil
        return true
    }
    
    private func validatePassword() -> Bool {
        if password.isEmpty {
            passwordError = "Required fields cannot be left blank."
            return false
        }
        
        passwordError = nil
        return true
    }
}
