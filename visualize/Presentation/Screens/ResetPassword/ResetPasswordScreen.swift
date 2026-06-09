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
struct ResetPasswordScreen: View {
    @Environment(AppCoordinator.self) private var coordinator
    
    // MARK: - State
    
    /// ViewModel that manages the state and logic of the screen
    @State private var viewModel: ResetPasswordScreenViewModel
    
    /// Initializes the view with its corresponding ViewModel
    ///
    /// - Parameter viewModel: ViewModel that handles reset password logic
    init(viewModel: ResetPasswordScreenViewModel) {
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
                        .foregroundStyle(AppColors.Text.primary)
                        .frame(width: 48, height: 48)
                        .glassEffect()
                }
                .padding(.top, 22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 24)
                
                // MARK: - Title
                
                Text("Reset password")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppColors.Text.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .padding(.bottom, 30)
                
                // MARK: - Description
                
                Text("Enter the email address associated with your account to receive a recovery link.")
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 38)
                    .padding(.bottom, 59)
                
                // MARK: - Email Input
                
                InputField(
                    placeholder: String(localized: "Email"),
                    text: $viewModel.email,
                    errorMessage: viewModel.emailError,
                    keyboardType: .emailAddress
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                // MARK: - Send Button
                
                AuthButton(title: String(localized: "Send")) {
                    viewModel.submit()
                }
                
                // MARK: - App Version
                
                Text("V 1.0.0")
                    .font(.system(size: 11))
                    .foregroundStyle(
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
    ResetPasswordScreen(
        viewModel: ResetPasswordScreenViewModel(
            resetPasswordUseCase: ResetPasswordUseCase(
                authRepository: AuthRepositoryImpl(
                    source: AuthFirebaseDatasource()
                )
            )
        )
    )
    .environment(AppCoordinator())
}
