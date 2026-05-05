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

enum FeedState {
    case loading
    case loaded([VisualizationCard])
    case empty
    case error
}

@Observable
class FeedViewModel {
    var state: FeedState = .loading
    var visualizationFilter: VisualizationFilter
    let loadVisualizationsUseCase: LoadVisualizationsUseCase
    private var allVisualizations: [VisualizationCard] = []
    private let currentUserID: String = "e9Nk8XrxHJAtwN3Hf2FL"
    init(loadVisualizationsUseCase: LoadVisualizationsUseCase) {
        self.loadVisualizationsUseCase = loadVisualizationsUseCase
        self.visualizationFilter = .all
    }
    func setVisualizationFilter(_ filter: VisualizationFilter) {
        if filter == self.visualizationFilter { return }
        self.visualizationFilter = filter
        if !allVisualizations.isEmpty {
            applyLocalFilter()
        } else {
            loadData()
        }
    }
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
    // MARK: - Load Data
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
    func fetchInitialData() {
        loadData(forceRefresh: false)
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
        let viewModel = FeedViewModel(loadVisualizationsUseCase: useCase)
        return viewModel
    }
}
