//
//  ChartSuggestion.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 06/05/26.
//

/// A chart suggestion produced by the ML microservice for a given dataset.
struct ChartSuggestion: Identifiable {
    // MARK: - Properties
    /// The chart index returned by the microservice (0–4).
    let id: Int
    /// Display name suggested by the ML service.
    let name: String
    /// Resolved chart type enum value.
    let chartType: ChartType
    /// Fully parsed chart model, ready to be passed to `ChartRendererView`.
    let chart: ChartData
}
