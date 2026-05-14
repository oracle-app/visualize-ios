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

    // MARK: - Initialization

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    // MARK: - Actions

    /// Checks whether a user session is currently active.
    func checkSession() {
        isLoggedIn = authRepository.getCurrentUser() != nil
    }
}
