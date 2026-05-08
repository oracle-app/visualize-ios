//
//  Login.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//

import SwiftUI

// MARK: - Login View

/// Login screen built using SwiftUI.
///
/// This view is responsible for presenting the user interface for user authentication.
/// It includes:
/// - Email and password input fields
/// - Login action button
/// - Navigation entry point to sign-up flow
/// - Basic UI layout and branding elements
///
/// The view delegates all business logic to `LoginViewModel`.
struct Login: View {

    // MARK: - State
    
    @State private var viewModel: LoginViewModel
    @State private var isPasswordVisible = false
    
    // MARK: - Initialization
    
    /// Initializes the Login view with its corresponding ViewModel.
    ///
    /// - Parameter viewModel: The view model responsible for login logic and state.
    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header Image
            
            ZStack {
                Image("LoginBackg")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .padding(.bottom, 40)
            }
            .frame(height: 110)

            // MARK: - Content
            
            ScrollView {
                VStack(spacing: 0) {

                    // Title
                    Text("Welcome")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(Color.appNavy))
                        .multilineTextAlignment(.center)
                        .padding(.top, 58)
                        .padding(.bottom, 58)

                    // Email input
                    InputField(
                        placeholder: "Email",
                        text: $viewModel.email,
                        keyboardType: .emailAddress
                    )
                    .padding(.bottom, 28)

                    // Password input
                    PasswordField(
                        placeholder: "Password",
                        text: $viewModel.password,
                        isVisible: $isPasswordVisible
                    )
                    .padding(.bottom, 8)

                    // Forgot password action
                    HStack {
                        Spacer()
                        Button {
                            // functionality
                        } label: {
                            Text("Forgot your password?")
                                .font(.system(size: 13))
                                .foregroundColor(Color(Color.appSubtitle))
                                .underline()
                        }
                    }
                    .padding(.bottom, 36)

                    // Login button
                    AuthButton(title: "Log in") {
                        viewModel.login()
                    }
                    .padding(.bottom, 20)

                    // Sign up navigation
                    VStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(Color(Color.appSubtitle))

                        Button {
                            // Navigation
                        } label: {
                            Text("Sign up")
                                .font(.system(size: 15))
                                .foregroundColor(Color(red: 192/255, green: 130/255, blue: 60/255))
                                .underline()
                        }
                    }
                    .padding(.bottom, 16)

                    // App version
                    Text("V 1.0.0")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 121/255, green: 139/255, blue: 138/255).opacity(0.6))
                        .padding(.top, 129)
                }
                .scrollTargetLayout()
                .padding(.horizontal, 24)
            }
            .background(Color(red: 245/255, green: 244/255, blue: 242/255))
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .ignoresSafeArea(edges: .bottom)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color(Color.appTeal))
    }
}

// MARK: - Preview

#Preview {
    Login(
        viewModel: LoginViewModel(
            loginUseCase: LoginUseCase(
                repository: AuthRepositoryImpl(
                    source: AuthFirebaseDatasource()
                )
            )
        )
    )
}
