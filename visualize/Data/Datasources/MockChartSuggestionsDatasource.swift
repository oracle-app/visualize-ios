//
//  MockChartSuggestionsDatasource.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 07/05/26.
//

import Foundation
/// Simulates the ML microservice by parsing bundled JSON strings from `MockChartJSONs`.
struct MockChartSuggestionsDatasource {
    /// Returns parsed suggestions after a simulated 2-second network delay.
    /// - Returns: Suggestions sorted ascending by chart index.
    /// - Throws: `CancellationError` if the enclosing Task is cancelled.
    func fetchSuggestions() async throws -> [ChartSuggestion] {
        try await Task.sleep(for: .seconds(2))
        return MockChartJSONs.allCharts
            .compactMap { ChartConfigParser.parseSuggestion(from: $0) }
            .sorted { $0.id < $1.id }
    }
}
