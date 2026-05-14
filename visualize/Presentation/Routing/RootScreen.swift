//
//  RootView.swift
//  visualize
//
//  Created by Libia Fv on 10/05/26.
//

import Foundation
import SwiftUI

// MARK: - Root Screen

/// Entry point of the app's navigation structure.
///
/// Owns the `NavigationStack` and the `AppCoordinator`, injecting
/// the coordinator as an environment object so all child views can
/// push and replace routes.
///
/// On appear, checks for an existing session and skips the landing
/// screen if the user is already authenticated.
struct RootScreen: View {
    
    // MARK: - State
    
    @State private var coordinator: AppCoordinator
    @State private var viewModel: RootViewModel
    
    // MARK: - Initialization
    init(viewModel: RootViewModel, coordinator: AppCoordinator) {
        _viewModel = State(initialValue: viewModel)
        _coordinator = State(initialValue: coordinator)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            LandingScreen()
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .login:
                        Login(viewModel: LoginViewModel(
                            loginUseCase: LoginUseCase(
                                repository: AuthRepositoryImpl(
                                    source: AuthFirebaseDatasource()
                                )
                            )
                        ))
                        .navigationBarBackButtonHidden(true)
                    case .signUp:
                        SignUp(viewModel: SignUpViewModel(
                            registerUseCase: RegisterUseCase(
                                authRepository: AuthRepositoryImpl(
                                    source: AuthFirebaseDatasource()
                                ),
                                userRepository: UserRepositoryImpl(
                                    userDatasource: UserDatasource()
                                )
                            )
                        ))
                        .navigationBarBackButtonHidden(true)
                    case .feed:
                        NavBar()
                            .navigationBarBackButtonHidden(true)
                            .toolbar(.hidden, for: .navigationBar)
                    case .resetPassword:
                        ResetPasswordView(
                            viewModel: ResetPasswordViewModel(
                                resetPasswordUseCase: ResetPasswordUseCase(
                                    authRepository: AuthRepositoryImpl(
                                        source: AuthFirebaseDatasource()
                                    )
                                )
                            )
                        )
                        .navigationBarBackButtonHidden(true)
                        
                    case .checkEmail(let email):
                        CheckEmailView(
                            viewModel: CheckEmailViewModel(
                                email: email,
                                resetPasswordUseCase: ResetPasswordUseCase(
                                    authRepository: AuthRepositoryImpl(
                                        source: AuthFirebaseDatasource()
                                    )
                                )
                            )
                        )
                        .navigationBarBackButtonHidden(true)
                    }
                }
                .onAppear {
                    viewModel.checkSession()
                    if viewModel.isLoggedIn {
                        coordinator.replace(path: [.feed])
                    }
                }
        }.environment(coordinator)
    }
}
