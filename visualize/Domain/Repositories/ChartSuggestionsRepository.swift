//
//  ChartSuggestionsRepository.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 06/05/26.
//

/// Contract for fetching ML-generated chart suggestions for a dataset.
///
/// Implementations:
/// - `APIChartSuggestionsRepositoryImpl` , calls the live microservice (production).
/// - `MockChartSuggestionsRepositoryImpl` , returns bundled Titanic JSON (previews and tests).

protocol ChartSuggestionsRepository {
    /// Returns chart suggestions for the dataset identified by `taskId`.
    /// - Parameter taskId: The identifier returned by `AnalyzeRepository.uploadDataset`.
    ///   Mock implementations may ignore this value and return a fixed dataset.
    /// - Returns: Suggestions sorted ascending by `chartIndex`.
    /// - Throws: Any networking or parsing error.
    func getSuggestions(taskId: String) async throws -> [ChartSuggestion]
}
