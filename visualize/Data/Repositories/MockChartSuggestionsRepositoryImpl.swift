//
//  MockChartSuggestionsRepositoryImpl.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 07/05/26.
//
//  Swap for APIChartSuggestionsRepositoryImpl when the endpoint is live.
//

/// Mock implementation of `ChartSuggestionsRepository` backed by bundled JSON strings.
/// Delegates to `MockChartSuggestionsDatasource`.
struct MockChartSuggestionsRepositoryImpl: ChartSuggestionsRepository {
    
    // MARK: - Dependencies
    private let datasource: MockChartSuggestionsDatasource = MockChartSuggestionsDatasource()
    
    // MARK: - ChartSuggestionsRepository
    func getSuggestions() async throws -> [ChartSuggestion] {
        try await datasource.fetchSuggestions()
    }
}
