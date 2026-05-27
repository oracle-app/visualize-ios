//
//  CheckEmail.swift
//  visualize
//
//  Created by Mariana Islas Mondragón on 05/05/26.
//

import SwiftUI

// MARK: - Check Email View

/// SwiftUI view responsible for informing the user to check their email.
///
/// This screen:
/// - Confirms that a password reset email has been sent
/// - Guides the user to follow the instructions in their inbox
/// - Provides an option to resend the email
/// - Allows navigation back to login
///
/// This view is purely presentational and does not handle business logic.
struct CheckEmailView: View {
    @Environment(AppCoordinator.self) private var coordinator
    
    @State private var viewModel: CheckEmailViewModel

    init(viewModel: CheckEmailViewModel) {
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
                
                // MARK: - Message Section
                
                VStack(spacing: 0) {
                    
                    // Title
                    
                    Text("Check your email")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(Color.appNavy))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .padding(.bottom, 30)
                    
                    // Description
                    
                    Text("Please click on the link sent to your email address to reset your password.")
                        .font(.system(size: 17))
                        .foregroundColor(Color(Color.appSubtitle))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 38)
                        .padding(.bottom, 25)
                    
                    // MARK: - Resend Email Option
                    
                    HStack {
                        Text("Didn't get the email?")
                        
                        Button {
                            viewModel.resend()
                        } label: {
                            Text(viewModel.isResending ? "Sending..." : "Resend email")
                                .underline()
                                .foregroundColor(Color(Color.primaryOrange))
                        }
                        .disabled(viewModel.isResending || viewModel.didResend)
                    }
                    .font(.system(size: 17))
                    .foregroundColor(Color(Color.appSubtitle))
                    .multilineTextAlignment(.center)
     
                }
                .frame(maxHeight: .infinity, alignment: .center)
                
                Spacer()
                
                // MARK: - Back to Login Button
                
                AuthButton(title: "Back to log in") {
                    coordinator.replace(path: [.login])
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
            .portraitOrientationLock()
        }
    }
}

// MARK: - Preview

#Preview {
    CheckEmailView(
        viewModel: CheckEmailViewModel(
            email: "user@example.com",
            resetPasswordUseCase: ResetPasswordUseCase(
                authRepository: AuthRepositoryImpl(
                    source: AuthFirebaseDatasource()
                )
            )
        )
    )
    .environment(AppCoordinator())
}
