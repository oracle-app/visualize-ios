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
    
    /// Chart suggestions produced by the ML service, passed from
    /// `GeneratingVisualizationsView` to `VizReadyView`.
    ///
    /// Stored here instead of in `AppRoute` because `ChartData`'s
    /// associated values (e.g. `[String: Double]`) are not `Hashable`,
    /// which is required for route enum cases.
    var pendingSuggestions: [ChartSuggestion] = []
    var createFlowResetID: Int = 0

    // MARK: - Tab State

    var selectedTab: Tabs = .feed
    var feedPath: [AppRoute] = []
    var createPath: [AppRoute] = []
    var teamsPath: [AppRoute] = []
    var profilePath: [AppRoute] = []


    // MARK: - Navigation

    func push(_ route: AppRoute) {
        if isAuthenticated {
            switch selectedTab {
            case .feed:
                feedPath.append(route)

            case .create:
                createPath.append(route)

            case .teams:
                teamsPath.append(route)

            case .profile:
                profilePath.append(route)
            }
        } else {
            path.append(route)
        }
    }

    func pop() {
        if isAuthenticated {
            switch selectedTab {
            case .feed:
                guard !feedPath.isEmpty else { return }
                feedPath.removeLast()

            case .create:
                guard !createPath.isEmpty else { return }
                createPath.removeLast()

            case .teams:
                guard !teamsPath.isEmpty else { return }
                teamsPath.removeLast()

            case .profile:
                guard !profilePath.isEmpty else { return }
                profilePath.removeLast()
            }
        } else {
            guard !path.isEmpty else { return }
            path.removeLast()
        }
    }

    func popToRoot() {
        if isAuthenticated {
            switch selectedTab {
            case .feed:
                feedPath.removeAll()

            case .create:
                createPath.removeAll()

            case .teams:
                teamsPath.removeAll()

            case .profile:
                profilePath.removeAll()
            }
        } else {
            path.removeAll()
        }
    }

    func replace(path newPath: [AppRoute]) {
        if isAuthenticated {
            switch selectedTab {
            case .feed:
                feedPath = newPath

            case .create:
                createPath = newPath

            case .teams:
                teamsPath = newPath

            case .profile:
                profilePath = newPath
            }
        } else {
            path = newPath
        }
    }

    // MARK: - Session

    func login() {
        clearAllPaths()
        selectedTab = .feed
        isAuthenticated = true
    }

    func logout() {
        isAuthenticated = false
        selectedTab = .feed
        clearAllPaths()
    }
    
    /// Clears the create flow's navigation and transient state explicitly.
    /// - Parameter shouldResetUpload: Whether `CreateVisualization` should reset its uploaded file state.
    func resetCreateFlow(shouldResetUpload: Bool = true) {
        createPath.removeAll()
        pendingSuggestions.removeAll()

        if shouldResetUpload {
            createFlowResetID += 1
        }
    }

    /// Completes the create flow after a successful share.
    func finishCreateFlow() {
        selectedTab = .feed
        resetCreateFlow()
    }
    
    /// Stores suggestions and pushes `.vizReady` in a single call.
    /// - Parameter suggestions: The chart suggestions to display in `VizReadyView`.
    func navigateToVizReady(with suggestions: [ChartSuggestion]) {
        pendingSuggestions = suggestions
        push(.vizReady)
    }
    // MARK: Helpers
    
    private func clearAllPaths() {
        path.removeAll()
        feedPath.removeAll()
        teamsPath.removeAll()
        profilePath.removeAll()
        resetCreateFlow(shouldResetUpload: true)
    }
}
