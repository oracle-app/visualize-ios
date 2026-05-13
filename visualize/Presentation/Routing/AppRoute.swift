//
//  AppRoute.swift
//  visualize
//
//  Created by Libia Fv on 10/05/26.
//

// MARK: - App Route

/// Defines all possible navigation destinations
/// within the main navigation stack.
///
/// Used by `AppCoordinator` to push and replace
/// screens via SwiftUI's `NavigationStack`.
enum AppRoute: Hashable {
    case login
    case signUp
    case feed
}

// MARK: - Root Route

/// Defines the root-level screen of the app,
/// displayed before any navigation occurs.
///
/// Separate from `AppRoute` since it lives outside
/// the `NavigationStack` path.
enum RootRoute {
    case landing
}
