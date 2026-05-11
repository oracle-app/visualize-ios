//
//  EditVisualizationViewModel.swift
//  VisualizeApp
//
//  Created by Zuleyca Guadalupe Balles Soto on 11/04/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class GeneratingVisualizationsViewModel {
    
    let title = "Generating Visualizations"
    let message = "We’re analyzing your dataset and generating charts that best represent your data."
    let footerMessage = "This may take a moment..."

    var isLoading = false
    var navigateToVizReady = false
    var dismissToUpload = false
    
    /// Chart suggestions returned by the repository; passed to `VizReadyView` on success.
    var suggestions: [ChartSuggestion] = []
 
    /// Non-nil when `startLoading` throws; displayed inline in the view.
    var errorMessage: String? = nil
 
    // MARK: - Dependencies
    /// Source of chart suggestions. Defaults to the mock.
    private let chartSuggestionsRepository: any ChartSuggestionsRepository
 
    // MARK: - Init
    init(chartSuggestionsRepository: any ChartSuggestionsRepository = MockChartSuggestionsRepositoryImpl()) {
        self.chartSuggestionsRepository = chartSuggestionsRepository
    }
 
    // MARK: - Intents
    /// Fetches chart suggestions from the repository and navigates to VizReady on success.
    func startLoading() async {
        isLoading = true
        errorMessage = nil
        do {
            suggestions = try await chartSuggestionsRepository.getSuggestions()
            navigateToVizReady = true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func onCancelTapped() {
        dismissToUpload = true
    }
}
