//
//  AppCoordinator.swift
//  visualize
//
//  Created by Libia Fv on 10/05/26.
//

import Foundation
import FirebaseAuth

@MainActor
@Observable
final class AppCoordinator {

    var isAuthenticated: Bool = false
    var path: [AppRoute] = []
    var root: RootRoute = .landing
    var pendingSuggestions: [ChartSuggestion] = []
    var createFlowResetID: Int = 0

    var selectedTab: Tabs = .feed
    var feedPath: [AppRoute] = []
    var createPath: [AppRoute] = []
    var teamsPath: [AppRoute] = []
    var profilePath: [AppRoute] = []

    var removeFCMTokenUseCase: RemoveFCMTokenUseCase?

    func push(_ route: AppRoute) {
        if isAuthenticated {
            switch selectedTab {
            case .feed:    feedPath.append(route)
            case .create:  createPath.append(route)
            case .teams:   teamsPath.append(route)
            case .profile: profilePath.append(route)
            }
        } else { path.append(route) }
    }

    func pop() {
        if isAuthenticated {
            switch selectedTab {
            case .feed:    guard !feedPath.isEmpty    else { return }; feedPath.removeLast()
            case .create:  guard !createPath.isEmpty  else { return }; createPath.removeLast()
            case .teams:   guard !teamsPath.isEmpty   else { return }; teamsPath.removeLast()
            case .profile: guard !profilePath.isEmpty else { return }; profilePath.removeLast()
            }
        } else { guard !path.isEmpty else { return }; path.removeLast() }
    }

    func popToRoot() {
        if isAuthenticated {
            switch selectedTab {
            case .feed:    feedPath.removeAll()
            case .create:  createPath.removeAll()
            case .teams:   teamsPath.removeAll()
            case .profile: profilePath.removeAll()
            }
        } else { path.removeAll() }
    }

    func replace(path newPath: [AppRoute]) {
        if isAuthenticated {
            switch selectedTab {
            case .feed:    feedPath = newPath
            case .create:  createPath = newPath
            case .teams:   teamsPath = newPath
            case .profile: profilePath = newPath
            }
        } else { path = newPath }
    }

    func login() {
        path.removeAll()
        isAuthenticated = true
    }

    func logout() {
        if let userID = Auth.auth().currentUser?.uid, let useCase = removeFCMTokenUseCase {
            Task {
                try? await useCase.execute(userID: userID)
            }
        }
        isAuthenticated = false
        path.removeAll()
        feedPath.removeAll()
        resetCreateFlow(shouldResetUpload: false)
        teamsPath.removeAll()
        profilePath.removeAll()
    }

    func resetCreateFlow(shouldResetUpload: Bool = true) {
        createPath.removeAll()
        pendingSuggestions.removeAll()
        if shouldResetUpload { createFlowResetID += 1 }
    }

    func finishCreateFlow() {
        selectedTab = .feed
        resetCreateFlow()
    }

    func navigateToVizReady(with suggestions: [ChartSuggestion]) {
        pendingSuggestions = suggestions
        push(.vizReady)
    }

    func navigateToNotifications() {
        selectedTab = .feed
        feedPath.removeAll()
        push(.notifications)
    }
}
