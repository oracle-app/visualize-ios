//
//  EditVisualizationViewModel.swift
//  VisualizeApp
//
//  Created by Zuleyca Guadalupe Balles Soto on 11/04/26.
//

import Foundation
import Observation

@Observable
final class GeneratingVisualizationsViewModel {
    let title = "Generating Visualizations"
    let message = "We’re analyzing your dataset and generating charts that best represent your data."
    let footerMessage = "This may take a moment..."

    var isLoading = true

    func onCancelTapped() {
        // TODO: Connect cancel action to navigation flow.
    }
}
