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

    // MARK: - Auth State

    var isAuthenticated: Bool = false
    var path: [AppRoute] = []
    var root: RootRoute = .landing

    // MARK: - Tab State

    var selectedTab: Tabs = .feed
    var feedPath: [AppRoute] = []
    var createPath: [AppRoute] = []
    var teamsPath: [AppRoute] = []
    var profilePath: [AppRoute] = []

    // MARK: - Auth Navigation

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func replace(path newPath: [AppRoute]) {
        path = newPath
    }

    // MARK: - Session

    func login() {
        path.removeAll()
        isAuthenticated = true
    }

    func logout() {
        isAuthenticated = false
        path.removeAll()
        feedPath.removeAll()
        createPath.removeAll()
        teamsPath.removeAll()
        profilePath.removeAll()
    }
}
