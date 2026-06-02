//
//  FeedViewModel.swift
//  Visualize
//
//  Created by Jorge Flores on 13/04/26.
//

//  This file contains the ViewModel responsible for managing the presentation logic
//  of the application's main feed. It handles fetching data from the associated service,
//  managing the different UI states (loading, loaded, empty, and error), and exposing
//  them to the view layer so the UI can reactively update.
//
//  It uses the @Observable macro to enable automatic SwiftUI updates without the need
//  for @Published, and defines a FeedItem struct as the basic model representing
//  each item displayed in the feed.
//

import SwiftUI
import Observation

// MARK: - Feed State

enum FeedState {
    case loading
    case loaded([VisualizationCard])
    case empty
    case error
}

// MARK: - ViewModel

@MainActor
@Observable
class FeedScreenViewModel {

    // MARK: - Feed State
    var state: FeedState = .loading

    // MARK: - Search State
    /// Bound to the search input; triggers a debounced search on every change.
    var searchQuery: String = "" {
        didSet { scheduleSearch() }
    }
    /// Results returned by the last completed search.
    var searchResults: [VisualizationCard] = []
    /// True while a search request is in flight.
    var isSearching: Bool = false
    var isSearchActive: Bool = false

    // MARK: - Dependencies
    var visualizationFilter: VisualizationFilter
    private let loadVisualizationsUseCase: LoadVisualizationsUseCase
    private let searchVisualizationsUseCase: SearchVisualizationsUseCase
    private let hideVisualizationUseCase: HideVisualizationUseCase
    private let deleteVisualizationUseCase: DeleteVisualizationUseCase
    private let authRepository: any AuthRepository
    private let notificationRepository: any NotificationRepository

    var hasUnreadNotifications: Bool = false
    private var allVisualizations: [VisualizationCard] = []
    private(set) var currentUserID: String = ""
    var currentToast: Toast? = nil

    /// Search task used for debounce — ignored by @Observable to avoid tracking issues.
    @ObservationIgnored
    private var searchTask: Task<Void, Never>?
    private var toastTask: Task<Void, Never>?

    // MARK: - Initialization
    init(
        loadVisualizationsUseCase: LoadVisualizationsUseCase,
        searchVisualizationsUseCase: SearchVisualizationsUseCase,
        hideVisualizationUseCase: HideVisualizationUseCase,
        deleteVisualizationUseCase: DeleteVisualizationUseCase,
        authRepository: any AuthRepository,
        notificationRepository: any NotificationRepository
    ) {
        self.loadVisualizationsUseCase = loadVisualizationsUseCase
        self.searchVisualizationsUseCase = searchVisualizationsUseCase
        self.hideVisualizationUseCase = hideVisualizationUseCase
        self.deleteVisualizationUseCase = deleteVisualizationUseCase
        self.authRepository = authRepository
        self.notificationRepository = notificationRepository
        self.visualizationFilter = .all
        Task {
            await initializeUser()
        }
    }
    
    private func initializeUser() async {
        do {
            self.currentUserID = try await authRepository.getCurrentUserID()
            self.loadData(forceRefresh: false)
        } catch {
            self.state = .error
        }
    }
    
    func listenForUnreadNotifications() async {
        guard !currentUserID.isEmpty else { return }
            
        let stream = notificationRepository.unreadStream(for: currentUserID)
        for await hasUnread in stream {
            self.hasUnreadNotifications = hasUnread
        }
    }

    // MARK: - Filter
    /// Updates the active feed filter and reloads data if the filter changed.
    func setVisualizationFilter(_ filter: VisualizationFilter) {
        if filter == self.visualizationFilter { return }
        self.visualizationFilter = filter
        if !allVisualizations.isEmpty {
            applyLocalFilter()
        } else {
            loadData()
        }
    }

    /// Filters the cached visualizations locally without a network call.
    private func applyLocalFilter() {
        var filteredItems: [VisualizationCard] = []
        switch visualizationFilter {
        case .all:
            filteredItems = allVisualizations
        case .personal:
            filteredItems = allVisualizations.filter { $0.authorID == currentUserID }
        case .shared:
            filteredItems = allVisualizations.filter { $0.authorID != currentUserID }
        }
        state = filteredItems.isEmpty ? .empty : .loaded(filteredItems)
    }

    // MARK: - Search
    /// Cancels any pending search and schedules a new one after a debounce delay.
    private func scheduleSearch() {
        guard searchQuery.count >= 2 else {
            searchResults = []
            return
        }
        let query = searchQuery.lowercased()
        searchResults = allVisualizations.filter {
            $0.title.lowercased().contains(query)
        }
    }

    /// Executes the search and updates `searchResults` with the returned cards.
    private func performSearch() async {
        do {
            let results = try await searchVisualizationsUseCase.execute(
                userID: currentUserID,
                query: searchQuery
            )
            searchResults = results
        } catch {
            print(error)
            searchResults = []
        }
        isSearching = false
    }

    /// Resets all search state and cancels any in-flight search task.
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        isSearching = false
        searchTask?.cancel()
    }
    
    // MARK: - Toast
    /// Shows a toast and auto-dismisses it after a short delay.
    func showToast(_ toast: Toast) {
        toastTask?.cancel()
        currentToast = toast
        toastTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            currentToast = nil
        }
    }

    // MARK: - Load Data
    /// Fetches all visualizations and applies the active filter. Uses cache unless forceRefresh is true.
    func loadData(forceRefresh: Bool = false) {
        if forceRefresh {
            allVisualizations.removeAll()
        }
        
        guard allVisualizations.isEmpty else {
            Task {
                do {
                    let items = try await loadVisualizationsUseCase.execute(userID: currentUserID)
                    applyDiff(newItems: items)
                } catch {
                }
            }
            return
        }
        state = .loading
        
        Task {
            do {
                let items = try await loadVisualizationsUseCase.execute(
                    userID: currentUserID
                )
                self.allVisualizations = items
                applyLocalFilter()
            } catch {
                state = .error
            }
        }
    }
    

    /// Merges a fresh list of visualizations into the local cache without a full reload.
    /// This preserves scroll position and avoids unnecessary view refreshes.
    private func applyDiff(newItems: [VisualizationCard]) {
        // Remove items that no longer exist in the new list
        let newIDs = newItems.map(\.id)
        let oldIDs = allVisualizations.map(\.id)

        allVisualizations.removeAll { !newIDs.contains($0.id) }

        // Update existing items in place if their content changed
        for new in newItems {
            if let idx = allVisualizations.firstIndex(where: { $0.id == new.id }) {
                if allVisualizations[idx] != new {
                    allVisualizations[idx] = new
                }
            }
        }

        // Insert new items that didn't exist before, preserving server-side order
        for (offset, new) in newItems.enumerated() {
            if !oldIDs.contains(new.id) {
                let insertAt = min(offset, allVisualizations.count)
                allVisualizations.insert(new, at: insertAt)
            }
        }

        // Re-apply the active filter to reflect all changes in the UI
        applyLocalFilter()
    }
    
    /// Loads data on first appear without forcing a refresh.
    func fetchInitialData() {
        if !allVisualizations.isEmpty { return }
        if !currentUserID.isEmpty {
            loadData(forceRefresh: false)
        }
    }
    
    // MARK: - Delete Actions
    func hideVisualization(visualizationID: String) {
        Task {
            do {
                try await hideVisualizationUseCase.execute(userID: currentUserID, visualizationID: visualizationID)
                allVisualizations.removeAll { $0.id == visualizationID }
                searchResults.removeAll { $0.id == visualizationID }
                applyLocalFilter()
                await showToast(Toast(message: String(localized: "Visualization removed from your feed"), type: .success))
            } catch {
                print("Error hiding visualization: \(error)")
                await showToast(Toast(message: String(localized: "Failed to remove visualization"), type: .error))
            }
        }
    }
    func deleteVisualization(visualizationID: String) {
        Task {
            do {
                try await deleteVisualizationUseCase.execute(visualizationID: visualizationID)
                allVisualizations.removeAll { $0.id == visualizationID }
                searchResults.removeAll { $0.id == visualizationID }
                applyLocalFilter()
                await showToast(Toast(message: String(localized: "Visualization deleted for everyone"), type: .success))
            } catch {
                print("Error deleting visualization: \(error)")
                await showToast(Toast(message: String(localized: "Failed to delete visualization"), type: .error))
            }
        }
    }
}

// MARK: - Preview

extension FeedScreenViewModel {
    static var preview: FeedScreenViewModel {
        let userDS = UserDatasource()
        let teamDS = TeamDatasource()
        let authDS = AuthFirebaseDatasource()
        let notiDS = NotificationDatasource()
        let visualizationDS = VisualizationDatasource(userDatasource: userDS, teamsDatasource: teamDS)
        let repo = VisualizationRepositoryImpl(
            userDatasource: userDS,
            visualizationDatasource: visualizationDS,
            teamsDatasource: teamDS
        )
        let userRepo = UserRepositoryImpl(userDatasource: userDS)
        let authRepo = AuthRepositoryImpl(source: authDS)
        let notificationRepo = NotificationRepositoryImpl(datasource: notiDS)
        return FeedScreenViewModel(
            loadVisualizationsUseCase: LoadVisualizationsUseCase(visualizationRepository: repo),
            searchVisualizationsUseCase: SearchVisualizationsUseCase(visualizationRepository: repo),
            hideVisualizationUseCase: HideVisualizationUseCase(userRepository: userRepo, visualizationRepository: repo),
            deleteVisualizationUseCase: DeleteVisualizationUseCase(visualizationRepository: repo),
            authRepository: authRepo,
            notificationRepository: notificationRepo
        )
    }
}
