//
//  RootViewModel.swift
//  visualize
//
//  Created by Libia Fv on 11/05/26.
//

import Foundation

// MARK: - Root ViewModel

/// ViewModel for `RootScreen`, responsible for determining
/// whether an active session exists on app launch.
///
/// If a current user is found, `RootScreen` skips the landing
/// screen and navigates directly to the feed.
@MainActor
@Observable
class RootViewModel {

    // MARK: - State

    var isLoggedIn: Bool = false

    // MARK: - Dependencies

    private let authRepository: AuthRepository
    private let userRepository: any UserRepository

    // MARK: - Initialization

    init(
        authRepository: AuthRepository,
        userRepository: any UserRepository
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }

    // MARK: - Actions

    /// Checks whether a user session is currently active.
    func checkSession(coordinator: AppCoordinator) async {
        guard authRepository.getCurrentUser() != nil else {
            self.isLoggedIn = false
            coordinator.isAuthenticated = false
            return
        }
        
        do {
            let uid = try await authRepository.getCurrentUserID()
            let user = try await userRepository.getUserByID(userID: uid)
            
            coordinator.currentUser = user
            self.isLoggedIn = true
            coordinator.isAuthenticated = true
        } catch {
            self.isLoggedIn = false
            coordinator.isAuthenticated = false
        }
    }
}
