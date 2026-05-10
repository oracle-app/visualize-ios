//
//  ChartSuggestionsRepository.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 06/05/26.
//

/// Contract for fetching ML-generated chart suggestions for a dataset.
///
/// Implementations:
/// - `MockChartSuggestionsRepositoryImpl` — reads bundled JSON (current)
protocol ChartSuggestionsRepository {
    /// Returns chart suggestions for the most recently uploaded dataset.
    /// - Throws: Any networking or parsing error.
    func getSuggestions() async throws -> [ChartSuggestion]
}
