//
//  LoginViewModel.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//

import Foundation
import Observation
import FirebaseAuth

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
@MainActor
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
    var isLoading: Bool = false
    var isLoggedIn: Bool = false
    
    // Toast
    var currentToast: Toast? = nil

    @ObservationIgnored
    private var toastTask: Task<Void, Never>?
    
    // MARK: - Dependencies
    
    private let loginUseCase: LoginUseCase
    
    // MARK: - Initialization
    
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    // MARK: - Toast

    func showToast(_ toast: Toast) {
        toastTask?.cancel()
        currentToast = toast
        toastTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            currentToast = nil
        }
    }
    
    // MARK: - Actions
    
    func login() {
        
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
                isLoggedIn = true
                
            } catch let error as LoginError {
                switch error {
                case .emailRequired, .invalidEmail:
                    self.emailError = "Please enter a valid email address."
                case .passwordRequired:
                    self.passwordError = "Required fields cannot be left blank."
                }
                
            } catch let error as NSError {
                let code = AuthErrorCode(rawValue: error.code)
                switch code {
                case .wrongPassword, .invalidCredential, .userNotFound:
                    showToast(Toast(
                        message: "Incorrect email or password. Please try again.",
                        type: .error
                    ))
                case .networkError:
                    showToast(Toast(
                        message: "Unable to connect. Check your internet connection.",
                        type: .error
                    ))
                default:
                    showToast(Toast(
                        message: "Something went wrong. Please try again.",
                        type: .error
                    ))
                }
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
