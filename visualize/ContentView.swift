//
//  ContentView.swift
//  visualize
//
//  Created by Carlos Amador on 11/04/26.
//

import SwiftUI

/// Root view that switches between the login screen and the main app
/// based on the current authentication session state.
struct ContentView: View {

    // MARK: - State properties

    @State private var sessionManager: SessionManager

    // MARK: - Private properties

    private let authRepository: AuthRepository

    // MARK: - Initialization

    /// Initializes the root view with an authentication repository.
    ///
    /// Checks whether a user session exists to determine the initial screen.
    ///
    /// - Parameter authRepository: The repository used to verify the current session.
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
        let isLoggedIn: Bool = authRepository.getCurrentUser() != nil
        _sessionManager = State(initialValue: SessionManager(isLoggedIn: isLoggedIn))
    }

    // MARK: - Internal properties

    var body: some View {
        if sessionManager.isLoggedIn {
            NavBar(sessionManager: sessionManager)
        } else {
            Login(
                viewModel: LoginViewModel(
                    loginUseCase: LoginUseCase(repository: authRepository),
                    sessionManager: sessionManager
                )
            )
        }
    }
}

#Preview {
    ContentView(
        authRepository: AuthRepositoryImpl(source: AuthFirebaseDatasource())
    )
}
