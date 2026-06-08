//
//  VizReadyScreenViewModel.swift
//  visualize
//
//  Created by Nicolás Peralta on 15/04/26.
//

import SwiftUI

/// Manages state and business logic for the visualization selection flow.
/// Supports selecting one or more charts from the generated suggestions.
@MainActor
@Observable
final class VizReadyScreenViewModel {

    // MARK: - Constants
    /// Maximum number of characters allowed in a chart title.
    static let titleCharLimit: Int = 50

    // MARK: - State
    /// The list of chart suggestions produced by the ML service (or mock).
    var suggestions: [ChartSuggestion]
    
    /// User-edited titles keyed by chart index. Falls back to `suggestion.name` when absent.
    private var editedTitles: [Int: String] = [:]

    /// IDs of the currently selected charts. Supports multi-selection (1 to N).
    private(set) var selectedIDs: Set<Int> = []
    
    /// Validation error message for the last title update attempt; `nil` when valid.
    var titleValidationError: String? = nil

    // MARK: - Init
    /// - Parameter suggestions: Chart suggestions to display. Pass `[]` for empty state.
    init(suggestions: [ChartSuggestion] = []) {
        self.suggestions = suggestions
    }

    // MARK: - Computed
    /// `true` when the user has selected at least one chart.
    var isSelectionValid: Bool { !selectedIDs.isEmpty }
    
    /// The currently selected `ChartSuggestion` objects, in their original order.
    /// Used by `VizReadyScreen` to pass chart data to `ShareSheetViewModel`.
    var selectedSuggestions: [ChartSuggestion] {
        suggestions.filter { selectedIDs.contains($0.id) }
    }

    /// Returns the user-edited title for a suggestion, or the original ML name.
    /// - Parameter suggestion: The suggestion to resolve the title for.
    /// - Returns: The display title string.
    func displayTitle(for suggestion: ChartSuggestion) -> String {
        editedTitles[suggestion.id] ?? suggestion.name
    }

    /// Returns `true` if the given index is in the current selection set.
        func isSelected(_ id: Int) -> Bool { selectedIDs.contains(id) }

    // MARK: - Intents
    /// Toggles the chart at `id` in or out of the selection set.
    func toggleSelection(for id: Int) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    /// Updates the user-visible title for the chart at `id`.
    /// - Parameters:
    ///   - newTitle: The new title string entered by the user.
    ///   - id: The chart index to update.
    func updateTitle(_ newTitle: String, forID id: Int) {
        let trimmed: String = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            titleValidationError = String(localized: "Title cannot be empty")
            return
        }
        guard trimmed.count <= Self.titleCharLimit else {
            titleValidationError = String(localized: "Title exceeds character limit")
            return
        }
        titleValidationError = nil
        editedTitles[id] = trimmed
    }
}
