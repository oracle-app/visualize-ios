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

    /// Maximum number of characters allowed in a chart title.
    static let titleCharLimit = 50

    // MARK: - State

    /// The list of chart recommendations displayed to the user.
    var charts: [ChartOption] = [
        ChartOption(title: "Commerce Activity: Units Sold", author: "Mariana Islas"),
        ChartOption(title: "Units Sold Growth Trend", author: "Mariana Islas"),
        ChartOption(title: "Monthly Performance Overview", author: "Mariana Islas")
    ]

    /// The ID of the currently selected chart, or `nil` if none is selected.
    private(set) var selectedChartID: UUID?

    /// Validation error message for the last title update attempt; `nil` when valid.
    var titleValidationError: String?

    // MARK: - Computed

    /// `true` when the user has selected a single chart.
    var isSelectionValid: Bool { selectedChartID != nil }

    /// Returns `true` if the given ID matches the current selection.
    func isSelected(_ id: UUID) -> Bool {
        selectedChartID == id
    }

    // MARK: - Intents

    /// Selects the chart with the given ID, or deselects it if already selected.
    func toggleSelection(for id: UUID) {
        selectedChartID = (selectedChartID == id) ? nil : id
    }

    /// Updates the title of the chart identified by `id`.
    ///
    /// Silently ignores empty, blank, or unrecognised input.
    func updateTitle(_ newTitle: String, forID id: UUID) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            titleValidationError = "Title cannot be empty"
            return
        }
        guard trimmed.count <= Self.titleCharLimit else {
            titleValidationError = "Title exceeds character limit"
            return
        }
        guard let index = charts.firstIndex(where: { $0.id == id }) else { return }
        titleValidationError = nil
        charts[index].title = trimmed
    }
}
