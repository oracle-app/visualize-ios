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
/// - Basic UI layout anKd branding elements
///
/// The view delegates all business logic to `LoginViewModel`.
struct Login: View {
    @Environment(AppCoordinator.self) private var coordinator

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
                Image("AuthBackground")
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
                        errorMessage: viewModel.emailError,
                        keyboardType: .emailAddress
                    )
                    .padding(.bottom, 28)

                    // Password input
                    PasswordField(
                        placeholder: "Password",
                        text: $viewModel.password,
                        isVisible: $isPasswordVisible,
                        errorMessage: viewModel.passwordError
                    )
                    .padding(
                        .bottom,
                        (
                            viewModel.passwordError != nil &&
                            !viewModel.passwordError!.isEmpty
                        )
                        ? 28
                        : 8
                    )
                    .animation(
                        .easeInOut(duration: 0.2),
                        value: viewModel.passwordError
                    )

                    // Forgot password action
                    HStack {
                        Spacer()
                        Button {
                            coordinator.push(.resetPassword)
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
                            coordinator.push(.signUp)
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
            .background(Color.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .ignoresSafeArea(edges: .bottom)
            .scrollDismissesKeyboard(.interactively)
        }
        .overlay(alignment: .bottom) {
            if let toast = viewModel.currentToast {
                ToastView(toast: toast)
                    .padding(.bottom, 32)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity.combined(with: .scale(scale: 0.95))
                        )
                    )
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: viewModel.currentToast)
        .background(Color(Color.appTeal))
        .onChange(of: viewModel.isLoggedIn) { _, success in
            if success {
                coordinator.login()
            }
        }
        .portraitOrientationLock()
    }
}

// MARK: - Preview

#Preview {
    let repo = AuthRepositoryImpl(source: AuthFirebaseDatasource())
    Login(
        viewModel: LoginViewModel(
            loginUseCase: LoginUseCase(repository: repo)
        )
    )
    .environment(AppCoordinator())
}
