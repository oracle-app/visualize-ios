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
    
    let title = String(localized: "Generating Visualizations")
    let message = String(localized: "We're analyzing your dataset and generating charts that best represent your data.")
    let footerMessage = String(localized: "This may take a moment...")
 
    var isLoading: Bool = false
    
    /// Chart suggestions returned by the repository; passed to `VizReadyView` on success.
    var suggestions: [ChartSuggestion] = []
 
    /// Non-nil when `startLoading` throws; displayed inline in the view.
    var errorMessage: String? = nil
 
    // MARK: - Dependencies
    private let analyzeRepository: any AnalyzeRepository
    private let chartSuggestionsRepository: any ChartSuggestionsRepository
 
    // MARK: - Init
    init(
        analyzeRepository: any AnalyzeRepository = AnalyzeRepositoryImpl(),
        chartSuggestionsRepository: any ChartSuggestionsRepository = APIChartSuggestionsRepositoryImpl()
    ) {
        self.analyzeRepository = analyzeRepository
        self.chartSuggestionsRepository = chartSuggestionsRepository
    }
 
    // MARK: - Intents
    /// Uploads the dataset and fetches chart suggestions from the repository.
    /// The view reads `suggestions` after this returns and navigates via the coordinator.
    func startLoading(fileURL: URL) async {
        isLoading = true
        errorMessage = nil
        suggestions = []
        
        do {
            // Step 1: upload the file and obtain a task identifier.
            let id = try await analyzeRepository.uploadDataset(fileURL: fileURL)

            // Step 2: poll for the generated chart suggestions.
            suggestions = try await chartSuggestionsRepository.getSuggestions(taskId: id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
