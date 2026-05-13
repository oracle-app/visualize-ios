//
//  AppCoordinator.swift
//  visualize
//
//  Created by Libia Fv on 10/05/26.
//

import Foundation

// MARK: - App Coordinator

/// Central navigation coordinator for the application.
///
/// Manages the navigation stack using a path-based approach
/// compatible with SwiftUI's `NavigationStack`.
///
/// This coordinator:
/// - Tracks the current navigation path
/// - Provides actions to push, pop, and replace routes
/// - Is injected as an environment object across the app
@MainActor
@Observable
final class AppCoordinator {

    // MARK: - State

    /// The current navigation stack of routes.
    var path: [AppRoute] = []

    /// The root-level route of the app (e.g. landing screen).
    var root: RootRoute = .landing

    // MARK: - Navigation Actions

    /// Pushes a new route onto the navigation stack.
    ///
    /// - Parameter route: The destination route to navigate to.
    func push(_ route: AppRoute) {
        path.append(route)
    }

    /// Pops the last route from the navigation stack.
    ///
    /// Does nothing if the stack is already empty.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pops all routes, returning to the root screen.
    func popToRoot() {
        path.removeAll()
    }

    /// Replaces the entire navigation stack with a new path.
    ///
    /// Useful for flows like login → feed where back navigation
    /// to previous screens should not be allowed.
    ///
    /// - Parameter newPath: The new array of routes to set as the stack.
    func replace(path newPath: [AppRoute]) {
        path = newPath
    }
}
