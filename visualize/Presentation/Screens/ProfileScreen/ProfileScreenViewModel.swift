//
//  ProfileScreenViewModel.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 28/04/26.
//

import Observation

/// Defines the available chart color themes for the profile screen.
enum ChartColorTheme: String, CaseIterable, Identifiable {
    case aqua
    case iris
    case autumn
    case blossom

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .aqua:
            ""
        case .iris:
            ""
        case .autumn:
            ""
        case .blossom:
            ""
        }
    }
}

/// Manages the state and user actions for the profile screen.
@MainActor
@Observable
final class ProfileScreenViewModel {
    // MARK: - Internal properties

    private(set) var username: String = "Diana Escalante"
    private(set) var email: String = "dianaescalante@gmail.com"
    private(set) var selectedChartTheme: ChartColorTheme = .aqua

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

    let availableChartThemes: [ChartColorTheme] = ChartColorTheme.allCases

    // MARK: - Internal methods

    /// Updates the selected chart color theme.
    /// - Parameter theme: The chart color theme selected by the user.
    func selectChartTheme(_ theme: ChartColorTheme) {
        selectedChartTheme = theme
    }

    /// Handles the profile photo edit action.
    func editProfilePhoto() {
        // TODO: Implement in feature/profile-picture/select-from-gallery
    }

    /// Handles the logout action.
    func logOut() {
        // TODO: Implement in feature/authentication/logout
    }

    // MARK: - Private methods

    private func openTermsOfService() {
        // TODO: Implement in feature/profile/terms-of-service
    }

    private func openLicenses() {
        // TODO: Implement in feature/profile/licenses
    }
}
