//
//  MockChartSuggestionsRepositoryImpl.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 07/05/26.
//

/// Mock implementation of `ChartSuggestionsRepository` backed by bundled JSON strings.
/// Delegates to `MockChartSuggestionsDatasource`.
///
/// `taskId` is ignored since the mock always returns the same Titanic dataset
/// regardless of which task is requested. This allows development and UI testing
/// without a running microservice.
///
/// Swap the `GeneratingVisualizationsViewModel.init` default argument from `MockChartSuggestionsRepositoryImpl()` to `APIChartSuggestionsRepositoryImpl()` to connect to the live service.

struct MockChartSuggestionsRepositoryImpl: ChartSuggestionsRepository {
    
    // MARK: - Dependencies
    private let datasource: MockChartSuggestionsDatasource = MockChartSuggestionsDatasource()
    
    // MARK: - ChartSuggestionsRepository
    func getSuggestions(taskId: String) async throws -> [ChartSuggestion] {
        try await datasource.fetchSuggestions()
    }
}
