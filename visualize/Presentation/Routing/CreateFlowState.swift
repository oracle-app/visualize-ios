//
//  CreateFlowState.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 03/06/26.
//

import Foundation
 
// MARK: - Create Flow State
 
/// Holds transient state for the Create Visualization flow.
///
/// Extracted from `AppCoordinator` to follow the Single Responsibility Principle:
/// the coordinator handles navigation (push/pop/tab switching), while this object
/// owns the data that flows between screens during chart generation and publishing.
///
/// Injected via `.environment()` at the Create tab root in `NavBar` and accessed
/// by `CreateVisualizationScreen`, `GeneratingVisualizationsScreen`, and `VizReadyScreen`.
///

@MainActor
@Observable
final class CreateFlowState {
 
    /// Local URL of the dataset copied from the file importer.
    var pendingFileURL: URL?
 
    /// Chart suggestions produced by `GeneratingVisualizationsScreen`.
    var pendingSuggestions: [ChartSuggestion] = []
 
    /// Bumped after a successful share or discard to signal `CreateVisualizationScreen`
    /// to call `resetFile()`.
    var createFlowResetID: Int = 0
 
    /// Toast to display in `FeedScreen` after a successful create flow.
    var pendingToast: Toast?
 
    // MARK: - Lifecycle
 
    /// Resets all transient state for the Create flow.
    /// - Parameter shouldResetUpload: Whether to bump `createFlowResetID` so
    ///   `CreateVisualizationScreen` resets the uploaded file state.
    func reset(shouldResetUpload: Bool = true) {
        pendingSuggestions.removeAll()
        pendingFileURL = nil
        if shouldResetUpload {
            createFlowResetID += 1
        }
    }
 
    // MARK: - Flow Orchestration
 
    /// Stores the dataset file URL and pushes the generating screen.
    /// - Parameters:
    ///   - fileURL: Stable local URL of the dataset (copied to temp dir).
    ///   - coordinator: App coordinator used to push the Create route.
    func startGeneration(with fileURL: URL, coordinator: AppCoordinator) {
        pendingFileURL = fileURL
        coordinator.pushCreate(.generatingVisualizations)
    }
 
    /// Stores suggestions and pushes the VizReady screen.
    /// - Parameters:
    ///   - suggestions: The chart suggestions to display.
    ///   - coordinator: App coordinator used to push the Create route.
    func navigateToVizReady(with suggestions: [ChartSuggestion], coordinator: AppCoordinator) {
        pendingSuggestions = suggestions
        coordinator.pushCreate(.vizReady)
    }
 
    /// Clears the create flow's navigation and transient state explicitly.
    /// - Parameters:
    ///   - coordinator: App coordinator whose `createPath` will be cleared.
    ///   - shouldResetUpload: Whether `CreateVisualizationScreen` should reset its uploaded file state.
    func resetCreateFlow(coordinator: AppCoordinator, shouldResetUpload: Bool = true) {
        coordinator.createPath.removeAll()
        reset(shouldResetUpload: shouldResetUpload)
    }
 
    /// Completes the create flow after a successful share.
    /// Switches to the Feed tab and clears the Create flow state and navigation.
    /// - Parameter coordinator: App coordinator for tab switching and path clearing.
    func finishCreateFlow(coordinator: AppCoordinator) {
        coordinator.selectedTab = .feed
        resetCreateFlow(coordinator: coordinator)
    }
}
