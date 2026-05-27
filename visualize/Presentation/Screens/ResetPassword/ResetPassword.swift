//
//  ResetPassword.swift
//  visualize
//
//  Created by Mariana Islas Mondragón on 05/05/26.
//

import SwiftUI

// MARK: - Reset Password View

/// SwiftUI view responsible for handling the password recovery flow.
///
/// This screen allows the user to:
/// - Enter their email address
/// - Request a password reset email
///
/// The view is focused only on UI and user interaction,
/// delegating logic to `ResetPasswordViewModel`.
struct ResetPasswordView: View {
    @Environment(AppCoordinator.self) private var coordinator
    
    // MARK: - State
    
    /// ViewModel that manages the state and logic of the screen
    @State private var viewModel: ResetPasswordViewModel
    
    /// Initializes the view with its corresponding ViewModel
    ///
    /// - Parameter viewModel: ViewModel that handles reset password logic
    init(viewModel: ResetPasswordViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header Image
            
            Image("AuthBackground")
                .resizable()
                .frame(height: 240)
                .scaledToFill()
                .clipped()
                .frame(height: 110)
            
            // MARK: - Content
            
            VStack(spacing: 0) {
                
                // MARK: - Back Button
                
                Button { coordinator.pop() } label: {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.primaryText)
                        .frame(width: 48, height: 48)
                        .glassEffect()
                }
                .padding(.top, 22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 24)
                
                // MARK: - Title
                
                Text("Reset password")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(Color.appNavy))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .padding(.bottom, 30)
                
                // MARK: - Description
                
                Text("Enter the email address associated with your account to receive a recovery link.")
                    .font(.system(size: 17))
                    .foregroundColor(Color(Color.appSubtitle))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 38)
                    .padding(.bottom, 59)
                
                // MARK: - Email Input
                
                InputField(
                    placeholder: "Email",
                    text: $viewModel.email,
                    errorMessage: viewModel.emailError,
                    keyboardType: .emailAddress
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                // MARK: - Send Button
                
                AuthButton(title: "Send") {
                    viewModel.submit()
                }
                
                // MARK: - App Version
                
                Text("V 1.0.0")
                    .font(.system(size: 11))
                    .foregroundColor(
                        Color(red: 121/255, green: 139/255, blue: 138/255)
                            .opacity(0.6)
                    )
                    .padding(.top, 75)
                    .padding(.bottom, 85)
            }
            
            // MARK: - Background Styling
            
            .background(Color.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .frame(maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
        }
        .onChange(of: viewModel.didSendEmail) { _, sent in
            if sent {
                coordinator.push(.checkEmail(email: viewModel.email))
            }
        }
        .portraitOrientationLock()
    }
}

// MARK: - Preview

#Preview {
    ResetPasswordView(
        viewModel: ResetPasswordViewModel(
            resetPasswordUseCase: ResetPasswordUseCase(
                authRepository: AuthRepositoryImpl(
                    source: AuthFirebaseDatasource()
                )
            )
        )
    )
    .environment(AppCoordinator())
}
