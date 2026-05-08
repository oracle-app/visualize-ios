//
//  SignUp.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//

import SwiftUI

// MARK: - Sign Up View

/// Screen responsible for handling
/// user account registration.
///
/// Features:
/// - User input collection
/// - Inline validation feedback
/// - Password visibility toggling
/// - Keyboard-aware scrolling behavior
/// - Registration action handling
struct SignUp: View {

    // MARK: - State
    
    /// ViewModel responsible for managing
    /// registration state and validation.
    @State private var viewModel: SignUpViewModel
    
    /// Controls visibility of the password field.
    @State private var isPasswordVisible = false
    
    /// Controls visibility of the confirm password field.
    @State private var isConfirmPasswordVisible = false
    
    // MARK: - Initialization
    
    init(viewModel: SignUpViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // MARK: - Header Image
                
                ZStack {
                    Image("SignUpBackground")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 240)
                        .clipped()
                }
                .frame(height: 110)
                
                // MARK: - Content
                
                VStack(spacing: 0) {
                    
                    // MARK: Title
                    
                    Text("Create your account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(Color.appNavy))
                        .multilineTextAlignment(.center)
                        .padding(.top, 58)
                        .padding(.bottom, 58)

                    // MARK: Name Field
                    
                    InputField(
                        placeholder: "Name",
                        text: $viewModel.name,
                        errorMessage: viewModel.nameError
                    )
                    .padding(.bottom, 28)

                    // MARK: Email Field
                    
                    InputField(
                        placeholder: "Email",
                        text: $viewModel.email,
                        errorMessage: viewModel.emailError,
                        keyboardType: .emailAddress
                    )
                    .padding(.bottom, 28)

                    // MARK: Password Field
                    
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

                    // MARK: Confirm Password Field
                    
                    PasswordField(
                        placeholder: "Confirm password",
                        text: $viewModel.confirmPassword,
                        isVisible: $isConfirmPasswordVisible,
                        errorMessage: viewModel.confirmPasswordError
                    )
                    .padding(.bottom, 36)

                    // MARK: Sign Up Button
                    
                    AuthButton(title: "Sign up") {
                        viewModel.signUp()
                    }
                    .padding(.bottom, 20)

                    // MARK: Login Navigation
                    
                    VStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(Color(Color.appSubtitle))

                        Button {
                            // Navigation
                        } label: {
                            Text("Log in")
                                .font(.system(size: 15))
                                .foregroundColor(
                                    Color(
                                        red: 192/255,
                                        green: 130/255,
                                        blue: 60/255
                                    )
                                )
                                .underline()
                        }
                    }
                    .padding(.bottom, 16)

                    // MARK: App Version
                    
                    Text("V 1.0.0")
                        .font(.system(size: 11))
                        .foregroundColor(
                            Color(
                                red: 121/255,
                                green: 139/255,
                                blue: 138/255
                            )
                            .opacity(0.6)
                        )
                        .padding(.bottom, 40)
                }
                .frame(maxWidth: 360)
                .padding(.horizontal, 24)
                .background(
                    Color(
                        red: 245/255,
                        green: 244/255,
                        blue: 242/255
                    )
                    .frame(height: 800, alignment: .top)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 30)
                    ),
                    alignment: .top
                )
            }
        }
        .background(
            Color(Color.appTeal)
                .ignoresSafeArea()
        )
        
        /// Allows the keyboard to dismiss interactively
        /// while scrolling.
        .scrollDismissesKeyboard(.interactively)
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
