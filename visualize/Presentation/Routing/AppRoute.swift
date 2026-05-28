//
//  AppRoute.swift
//  visualize
//
//  Created by Libia Fv on 10/05/26.
//

// MARK: - App Route

/// Auth-flow navigation destinations, pushed onto `AppCoordinator.path`
/// while the user is not authenticated.
///
/// Used by `AppCoordinator` to push and replace
/// screens via SwiftUI's `NavigationStack`.
enum AppRoute: Hashable {
    case login
    case signUp
    case resetPassword
    case checkEmail(email: String)
    case generatingVisualizations
    case vizReady
    case notifications
}

enum RootRoute {
    case landing
}
