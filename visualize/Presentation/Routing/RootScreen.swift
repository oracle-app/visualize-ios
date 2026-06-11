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
        Group {
            if coordinator.isAuthenticated {
                NavBarView()
            } else {
                NavigationStack(path: $coordinator.path) {
                    LandingScreen()
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .login:
                                Login(
                                    viewModel: LoginViewModel(
                                        loginUseCase: LoginUseCase(
                                            repository: AuthRepositoryImpl(
                                                source: AuthFirebaseDatasource()
                                            )
                                        ), userRepository: UserRepositoryImpl(userDatasource: UserDatasource())
                                    )
                                )
                                .navigationBarBackButtonHidden(true)
                            case .signUp:
                                SignUpScreen(
                                    viewModel: SignUpScreenViewModel(
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
                                .navigationBarBackButtonHidden(true)
                            case .resetPassword:
                                ResetPasswordScreen(
                                    viewModel: ResetPasswordScreenViewModel(
                                        resetPasswordUseCase: ResetPasswordUseCase(
                                            authRepository: AuthRepositoryImpl(
                                                source: AuthFirebaseDatasource()
                                            )
                                        )
                                    )
                                )
                                .navigationBarBackButtonHidden(true)
                            case .checkEmail(let email):
                                CheckEmailScreen(
                                    viewModel: CheckEmailScreenViewModel(
                                        email: email,
                                        resetPasswordUseCase: ResetPasswordUseCase(
                                            authRepository: AuthRepositoryImpl(
                                                source: AuthFirebaseDatasource()
                                            )
                                        )
                                    )
                                )
                                .navigationBarBackButtonHidden(true)

                            // These routes belong to the Create tab and are registered
                            // in NavBar's Create NavigationStack. They are listed here
                            // only to satisfy switch exhaustiveness, they are never
                            // pushed onto the auth path.
                            case .generatingVisualizations, .vizReady, .notifications:
                                EmptyView()
                            }
                        }
                }
            }
        }
        .environment(coordinator)
        .task {
            await viewModel.checkSession(coordinator: coordinator)
        }
    }
}
