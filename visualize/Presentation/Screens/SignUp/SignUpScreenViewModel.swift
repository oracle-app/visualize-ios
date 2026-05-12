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
/// - Stores user input fields
/// - Validates form values
/// - Handles registration flow
/// - Manages validation and loading states
///
/// Uses `@Observable` so the UI updates automatically
/// whenever any observable property changes.
@MainActor
@Observable
class SignUpViewModel {
    
    // MARK: - Input State
    
    /// User full name input.
    ///
    /// Revalidates automatically if an error is already present.
    var name = "" {
        didSet {
            if nameError != nil {
                _ = validateName()
            }
        }
    }
    
    /// User email input.
    ///
    /// Revalidates automatically while editing after an error appears.
    var email = "" {
        didSet {
            if emailError != nil {
                _ = validateEmail()
            }
        }
    }
    
    /// User password input.
    ///
    /// Revalidates automatically while editing after an error appears.
    var password = "" {
        didSet {
            if passwordError != nil {
                _ = validatePassword()
            }
        }
    }
    
    /// User confirm password input.
    ///
    /// Revalidates automatically while editing after an error appears.
    var confirmPassword = "" {
        didSet {
            if confirmPasswordError != nil {
                _ = validateConfirmPassword()
            }
        }
    }
    
    // MARK: - UI Error State
    
    /// Validation error for the name field.
    var nameError: String? = nil
    
    /// Validation error for the email field.
    var emailError: String? = nil
    
    /// Validation error for the password field.
    var passwordError: String? = nil
    
    /// Validation error for the confirm password field.
    var confirmPasswordError: String? = nil
    
    /// Generic error message for unexpected failures.
    var errorMessage: String? = nil
    
    /// Indicates whether a registration request is currently running.
    var isLoading: Bool = false
    
    var isRegistered: Bool = false
    
    // MARK: - Dependencies
    
    /// Use case responsible for user registration logic.
    private let registerUseCase: RegisterUseCase
    
    // MARK: - Initialization
    
    /// Creates a new instance of the SignUpViewModel.
    ///
    /// - Parameter registerUseCase:
    /// Business use case used to register users.
    init(registerUseCase: RegisterUseCase) {
        self.registerUseCase = registerUseCase
    }
    
    // MARK: - Actions
    
    /// Validates all form fields and starts the registration process.
    ///
    /// If validation fails, the corresponding field errors
    /// are updated and registration is cancelled.
    /// Registration errors returned by Firebase are also mapped
    /// to user-friendly UI error messages.
    func signUp() {
        errorMessage = nil
        
        let isNameValid = validateName()
        let isEmailValid = validateEmail()
        let isPasswordValid = validatePassword()
        let isConfirmValid = validateConfirmPassword()
        
        guard isNameValid &&
                isEmailValid &&
                isPasswordValid &&
                isConfirmValid else {
            return
        }
        
        Task {
            isLoading = true
            
            do {
                let user = try await registerUseCase.execute(
                    email: email,
                    password: password,
                    username: name
                )
                
                print("Registered: \(user)")
                isRegistered = true
                
            } catch let error as RegisterError {
                
                switch error {
                case .emailAlreadyInUse:
                    self.emailError = "This email is already registered."
                case .invalidEmail:
                    self.emailError = "This email is invalid."
                    
                default:
                    self.errorMessage = error.localizedDescription
                }
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Validation
    
    /// Validates the name field.
    ///
    /// Rules:
    /// - Cannot be empty
    /// - Must contain at least 2 characters
    ///
    /// - Returns: `true` if valid, otherwise `false`.
    private func validateName() -> Bool {
        
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "Required fields cannot be left blank."
            return false
            
        } else if name.count < 2 {
            nameError = "Name must be at least 2 characters."
            return false
        }
        
        nameError = nil
        return true
    }
    
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
    
    /// Validates the password field.
    ///
    /// Rules:
    /// - Cannot be empty
    /// - Must contain at least 12 characters
    /// - Must contain letters and numbers
    /// - Must contain at least one special character
    ///
    /// - Returns: `true` if valid, otherwise `false`.
    private func validatePassword() -> Bool {
        
        if password.isEmpty {
            passwordError = "Required fields cannot be left blank."
            return false
        }
        
        if password.count < 12 {
            passwordError = "Password must be at least 12 characters."
            return false
        }
        
        let alphaNumericRegex = #"^(?=.*[A-Za-z])(?=.*\d).*$"#
        
        if !NSPredicate(format: "SELF MATCHES %@", alphaNumericRegex)
            .evaluate(with: password) {
            
            passwordError = "Password must include letters and numbers."
            return false
        }
        
        let specialCharRegex = #"^.*[$@$!%*#?&.].*$"#
        
        if !NSPredicate(format: "SELF MATCHES %@", specialCharRegex)
            .evaluate(with: password) {
            
            passwordError = "Password must include one of ($ @ ! % * # ? & .)."
            return false
        }
        
        passwordError = nil
        return true
    }
    
    /// Validates the confirm password field.
    ///
    /// Rules:
    /// - Cannot be empty
    /// - Must match the password field
    ///
    /// - Returns: `true` if valid, otherwise `false`.
    private func validateConfirmPassword() -> Bool {
        
        if confirmPassword.isEmpty {
            confirmPasswordError = "Required fields cannot be left blank."
            return false
            
        } else if password != confirmPassword {
            confirmPasswordError = "Passwords do not match."
            return false
        }
        
        confirmPasswordError = nil
        return true
    }
}
