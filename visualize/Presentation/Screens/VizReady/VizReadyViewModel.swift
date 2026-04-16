//
//  VizReadyViewModel.swift
//  visualize
//
//  Created by Nicolás Peralta on 15/04/26.
//

import SwiftUI

/// Manages state and business logic for the visualization selection flow.
@Observable
final class VizReadyViewModel {

    // MARK: - Constants
    static let titleCharLimit = 50

    // MARK: - State
    var charts: [ChartOption] = [
        ChartOption(title: "Commerce Activity: Units Sold", author: "Mariana Islas", date: "13 apr 2026"),
        ChartOption(title: "Units Sold Growth Trend",       author: "Mariana Islas", date: "13 apr 2026"),
        ChartOption(title: "Monthly Performance Overview",  author: "Mariana Islas", date: "13 apr 2026")
    ]

    private(set) var selectedChartID: UUID?

    // MARK: - Computed

    /// True when the user has selected a chart.
    var isSelectionValid: Bool { selectedChartID != nil }

    /// Returns true if the given ID matches the current selection.
    func isSelected(_ id: UUID) -> Bool {
        selectedChartID == id
    }

    // MARK: - Intents

    /// Selects the chart with the given ID, or deselects it if already selected.
    func toggleSelection(for id: UUID) {
        selectedChartID = (selectedChartID == id) ? nil : id
    }

    /// Updates the title of the chart at the specified index.
    /// Silently ignores empty or out-of-bounds input.
    func updateTitle(_ newTitle: String, forChartAt index: Int) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, charts.indices.contains(index) else { return }
        charts[index].title = trimmed
    }
}
