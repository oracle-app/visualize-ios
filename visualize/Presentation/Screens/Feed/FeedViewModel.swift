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

@Observable
class FeedViewModel {

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
    let loadVisualizationsUseCase: LoadVisualizationsUseCase
    let searchVisualizationsUseCase: SearchVisualizationsUseCase

    private var allVisualizations: [VisualizationCard] = []
    private let currentUserID: String = "e9Nk8XrxHJAtwN3Hf2FL"

    /// Search task used for debounce — ignored by @Observable to avoid tracking issues.
    @ObservationIgnored
    private var searchTask: Task<Void, Never>?

    // MARK: - Initialization
    init(loadVisualizationsUseCase: LoadVisualizationsUseCase,
         searchVisualizationsUseCase: SearchVisualizationsUseCase) {
        self.loadVisualizationsUseCase = loadVisualizationsUseCase
        self.searchVisualizationsUseCase = searchVisualizationsUseCase
        self.visualizationFilter = .all
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
        searchTask?.cancel()
        guard searchQuery.count >= 2 else {
            searchResults = []
            isSearching = false
            return
        }

        // Don't search again if we already have results for this query
        guard isSearching == false && searchResults.isEmpty else { return }

        isSearching = true
        searchTask = Task {
            /// Wait before firing the request to avoid querying on every keystroke.
            try? await Task.sleep(for: .milliseconds(400))
            if !Task.isCancelled {
                await performSearch()
            }
        }
    }

    /// Executes the search and updates `searchResults` with the returned cards.
    @MainActor
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

    // MARK: - Load Data
    /// Fetches all visualizations and applies the active filter. Uses cache unless forceRefresh is true.
    func loadData(forceRefresh: Bool = false) {
        if forceRefresh {
            allVisualizations.removeAll()
        }
        if allVisualizations.isEmpty {
            state = .loading
        }
        Task {
            do {
                let items = try await loadVisualizationsUseCase.execute(
                    userID: currentUserID
                )
                self.allVisualizations = items
                applyLocalFilter()
            } catch {
                print(error)
                state = .error
            }
        }
    }

    /// Loads data on first appear without forcing a refresh.
    func fetchInitialData() {
        loadData(forceRefresh: false)
    }
}

// MARK: - Preview

extension FeedViewModel {
    static var preview: FeedViewModel {
        let userDS = UserDatasource()
        let teamDS = TeamDatasource()
        let visualizationDS = VisualizationDatasource(
            userDatasource: userDS,
            teamsDatasource: teamDS
        )
        let repo = VisualizationRepositoryImpl(
            userDatasource: userDS,
            visualizationDatasource: visualizationDS,
            teamsDatasource: teamDS
        )
        let useCase = LoadVisualizationsUseCase(visualizationRepository: repo)
        let searchUseCase = SearchVisualizationsUseCase(visualizationRepository: repo)

        let viewModel = FeedViewModel(
            loadVisualizationsUseCase: useCase,
            searchVisualizationsUseCase: searchUseCase
        )
        viewModel.loadData()
        return viewModel
    }
}
