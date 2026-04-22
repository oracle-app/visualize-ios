//
//  EditVisualizationViewModel.swift
//  VisualizeApp
//
//  Created by Zuleyca Guadalupe Balles Soto on 11/04/26.
//

import Foundation
internal import Combine

@MainActor
final class GeneratingVisualizationsViewModel: ObservableObject {
    let title = "Generating Visualizations"
    let message = "We’re analyzing your dataset and generating charts that best represent your data."
    let footerMessage = "This may take a moment..."

    @Published var isLoading = true
    @Published var navigateToVizReady = false
    @Published var dismissToUpload = false

    init() {
        // TODO: Remove this mock delay — replace with real generation completion callback when microservice is connected
        Task {
            try? await Task.sleep(for: .seconds(3))
            isLoading = false
            navigateToVizReady = true
        }
    }

    func onCancelTapped() {
        dismissToUpload = true
    }
}
