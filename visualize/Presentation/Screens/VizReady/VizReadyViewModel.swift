//
//  VizReadyViewModel.swift
//  visualize
//
//  Created by Nicolás Peralta on 15/04/26.
//

import SwiftUI

/// Manages state and business logic for the visualization selection flow.
@MainActor
@Observable
final class VizReadyViewModel {

    // MARK: - Constants
    /// Maximum number of characters allowed in a chart title.
    static let titleCharLimit: Int = 50

    // MARK: - State
    /// The list of chart suggestions produced by the ML service (or mock).
    var suggestions: [ChartSuggestion]
    
    /// User-edited titles keyed by chart index. Falls back to `suggestion.name` when absent.
    private var editedTitles: [Int: String] = [:]

    /// The ID of the currently selected chart, or `nil` if none is selected.
    private(set) var selectedID: Int? = nil
    
    /// Validation error message for the last title update attempt; `nil` when valid.
    var titleValidationError: String? = nil

    // MARK: - Init
    /// - Parameter suggestions: Chart suggestions to display. Pass `[]` for empty state.
    init(suggestions: [ChartSuggestion] = []) {
        self.suggestions = suggestions
    }

    // MARK: - Computed
    /// `true` when the user has selected a single chart.
    var isSelectionValid: Bool { selectedID != nil }

    /// Returns the user-edited title for a suggestion, or the original ML name.
    /// - Parameter suggestion: The suggestion to resolve the title for.
    /// - Returns: The display title string.
    func displayTitle(for suggestion: ChartSuggestion) -> String {
        editedTitles[suggestion.id] ?? suggestion.name
    }

    /// Returns `true` if the given index matches the current selection.
    func isSelected(_ id: Int) -> Bool { selectedID == id }

    // MARK: - Intents
    /// Selects the chart at `id`, or deselects it if already selected.
    func toggleSelection(for id: Int) {
        selectedID = (selectedID == id) ? nil : id
    }

    /// Updates the user-visible title for the chart at `id`.
    /// - Parameters:
    ///   - newTitle: The new title string entered by the user.
    ///   - id: The chart index to update.
    func updateTitle(_ newTitle: String, forID id: Int) {
        let trimmed: String = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            titleValidationError = "Title cannot be empty"
            return
        }
        guard trimmed.count <= Self.titleCharLimit else {
            titleValidationError = "Title exceeds character limit"
            return
        }
        titleValidationError = nil
        editedTitles[id] = trimmed
    }
}
