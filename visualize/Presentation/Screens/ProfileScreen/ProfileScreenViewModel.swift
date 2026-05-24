//
//  ProfileScreenViewModel.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 28/04/26.
//

import Foundation
import Observation

/// Manages the state and user actions for the profile screen.
@MainActor
@Observable
final class ProfileScreenViewModel {
    // MARK: - Internal properties

    private(set) var username: String = ""
    private(set) var email: String = ""
    private(set) var profilePictureURL: URL?
    private(set) var isLoadingProfile: Bool = false
    private(set) var profileError: String?
    private(set) var logoutError: String?

    var aboutItems: [AboutItem] {
        [
            .info("Version 1.0.0"),
            .info("Developed by DreamTeam Corp."),
            .action("Terms of Service") { [weak self] in
                self?.openTermsOfService()
            },
            .action("Licenses and open source libraries") { [weak self] in
                self?.openLicenses()
            }
        ]
    }

    private(set) var isLoggedOut: Bool = false

    // MARK: - Private properties

    private let logoutUseCase: LogoutUseCase
    private let getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase

    // MARK: - Initialization

    init(
        logoutUseCase: LogoutUseCase,
        getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase
    ) {
        self.logoutUseCase = logoutUseCase
        self.getCurrentUserProfileUseCase = getCurrentUserProfileUseCase
    }

    // MARK: - Internal methods

    /// Loads the current user profile from the database.
    func loadProfile() {
        Task {
            isLoadingProfile = true
            do {
                let user: AppUser = try await getCurrentUserProfileUseCase.execute()
                username = user.username
                email = user.email
                if let urlString = user.profilePictureURL {
                    profilePictureURL = URL(string: urlString)
                }
            } catch {
                profileError = error.localizedDescription
            }
            isLoadingProfile = false
        }
    }

    /// Handles the profile photo edit action.
    func editProfilePhoto() {
        // TODO: Implement in feature/profile-picture/select-from-gallery
    }

    /// Handles the logout action.
    func logOut() {
        do {
            try logoutUseCase.execute()
            isLoggedOut = true
        } catch {
            logoutError = error.localizedDescription
        }
    }

    // MARK: - Private methods

    private func openTermsOfService() {
        // TODO: Implement in feature/profile/terms-of-service
    }

    private func openLicenses() {
        // TODO: Implement in feature/profile/licenses
    }
}
