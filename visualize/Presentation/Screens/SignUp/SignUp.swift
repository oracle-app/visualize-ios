//
//  SignUp.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//

import SwiftUI

// MARK: - Sign Up View

/// SwiftUI view responsible for user account creation.
///
/// This screen provides a structured interface for new user registration,
/// including input fields for personal data and authentication credentials.
///
/// The view delegates all business logic to `SignUpViewModel` following MVVM principles.
/// It focuses only on presentation and user interaction.
struct SignUp: View {

    // MARK: - State
    
    @State private var viewModel: SignUpViewModel
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    // MARK: - Initialization
    
    /// Initializes the SignUp view with its corresponding ViewModel.
    ///
    /// - Parameter viewModel: The ViewModel responsible for registration logic and state.
    init(viewModel: SignUpViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header Image
            
            ZStack {
                Image("SignUpBackg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipped()
            }
            .frame(height: 110)

            // MARK: - Content
            
            ScrollView {
                VStack(spacing: 0) {

                    // Title
                    Text("Create your account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(Color.appNavy))
                        .multilineTextAlignment(.center)
                        .padding(.top, 58)
                        .padding(.bottom, 58)

                    // Name input
                    InputField(
                        placeholder: "Name",
                        text: $viewModel.name
                    )
                    .padding(.bottom, 28)

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

                    // Confirm password input
                    PasswordField(
                        placeholder: "Confirm password",
                        text: $viewModel.confirmPassword,
                        isVisible: $isConfirmPasswordVisible
                    )
                    .padding(.bottom, 36)

                    // Sign up button
                    AuthButton(title: "Sign up", isEnabled: viewModel.isFormValid) {
                        viewModel.signUp()
                    }
                    .padding(.bottom, 20)

                    // Navigation to login
                    VStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(Color(Color.appSubtitle))

                        Button {
                            // Navigation
                        } label: {
                            Text("Log in")
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
                        .padding(.bottom, 40)
                }
                .scrollTargetLayout()
                .padding(.horizontal, 24)
            }
            .background(Color(red: 245/255, green: 244/255, blue: 242/255))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .ignoresSafeArea(edges: .bottom)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color(Color.appTeal))
    }
}

// MARK: - Preview

#Preview {
    SignUp(
        viewModel: SignUpViewModel(
            registerUseCase: RegisterUseCase(
                authRepository: AuthRepositoryImpl(
                    source: AuthFirebaseDatasource()
                ),
                userRepository: UserRepositoryImpl(
                    userDatasource: UserDatasource()
                )
            )
        )
    )
}
