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


@Observable
class FeedViewModel {
    var state: FeedState = .loading
    
    var searchQuery: String = "" {
            didSet { scheduleSearch() }
        }
    var searchResults: [VisualizationCard] = []
    var isSearching: Bool = false
    
    var visualizationFilter: VisualizationFilter
    let loadVisualizationsUseCase: LoadVisualizationsUseCase
    let searchVisualizationsUseCase: SearchVisualizationsUseCase
    
    private var searchTask: Task<Void, Never>?
    
    init(loadVisualizationsUseCase: LoadVisualizationsUseCase,
         searchVisualizationsUseCase: SearchVisualizationsUseCase) {
        self.loadVisualizationsUseCase = loadVisualizationsUseCase
        self.searchVisualizationsUseCase = searchVisualizationsUseCase
        self.visualizationFilter = .all
    }
    
    func setVisualizationFilter(_ filter: VisualizationFilter) {
        if filter == self.visualizationFilter { return }
        self.visualizationFilter = filter
        loadData()
    }
    enum FeedState {
        case loading
        case loaded([VisualizationCard])
        case empty
        case error
    }
    
    // MARK: - Search
    private func scheduleSearch() {
        searchTask?.cancel()
        guard searchQuery.count >= 2 else {
            searchResults = []
            isSearching = false
            return
        }
        isSearching = true
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            if !Task.isCancelled {
                await performSearch()
            }
        }
    }

    @MainActor
    private func performSearch() async {
        do {
            let results = try await searchVisualizationsUseCase.execute(
                userID: "e9Nk8XrxHJAtwN3Hf2FL",
                query: searchQuery
            )
            searchResults = results
        } catch {
            print(error)
            searchResults = []
        }
        isSearching = false
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
        isSearching = false
        searchTask?.cancel()
    }
    
    
    // MARK: - Load Data
    func loadData() {
        state = .loading
        Task {
            do {
                let items = try await loadVisualizationsUseCase.execute(userID: "e9Nk8XrxHJAtwN3Hf2FL", visualizationFilter: visualizationFilter)
                state = items.isEmpty ? .empty : .loaded(items)
            } catch {
                print(error)
                state = .error
            }
        }
    }
}

extension FeedViewModel {
    // MARK: - Preview
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
        let useCase = LoadVisualizationsUseCase(
            visualizationRepository: repo
        )
        let searchUseCase = SearchVisualizationsUseCase(visualizationRepository: repo)

        let viewModel = FeedViewModel(
            loadVisualizationsUseCase: useCase,
            searchVisualizationsUseCase: searchUseCase
        )
       
        viewModel.loadData()
        return viewModel
    }
}
