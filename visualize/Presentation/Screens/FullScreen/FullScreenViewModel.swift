//
//  FullScreenViewModel.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 27/04/26.
//

import Foundation
import Observation
import SwiftUI

// MARK: - IdentifiableImage

/// Thin `Identifiable` wrapper around `UIImage`.
/// Used to drive `.fullScreenCover(item:)` from `FullScreenViewModel`.
struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - FullScreenViewModel

@MainActor
@Observable
final class FullScreenViewModel {

    // MARK: - State

    var title: String?
    var author: String?
    var createdAt: String?
    var sharedWith: [Color]?

    var team: Team?
    var isLoading: Bool = false
    var error: String?

    // MARK: - Capture State

    var capturedChartImage: IdentifiableImage?
    var chartCaptureSize: CGSize = CGSize(width: 800, height: 380)
    var showCaptureError: Bool = false

    // MARK: - Dependencies

    private let teamRepository: any TeamRepository
    private let userID = "e9Nk8XrxHJAtwN3Hf2FL"

    // MARK: - Init

    init(teamRepository: any TeamRepository) {
        self.teamRepository = teamRepository
    }

    // MARK: - Data Loading

    func load(teamId: String) async {
        isLoading = true
        error = nil
        do {
            let owned = try await teamRepository.getTeamsUserOwns(userID: userID)
            let joined = try await teamRepository.getTeamsUserIsIn(userID: userID)
            let all = owned + joined
            team = all.first { $0.id == teamId }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    var members: [AppUser] {
        team?.members ?? []
    }

    // MARK: - Capture

    /// Builds `ChartRendererView` for the given `chart`, captures it off-screen at
    /// `chartCaptureSize`, and assigns the result to `capturedChartImage` to
    /// trigger `.fullScreenCover`.
    ///
    /// Uses `ViewSnapshot.captureAsync` because `ChartRendererView` embeds
    /// SciChart's Metal-backed `UIViewRepresentable`, whose first frame is
    /// presented asynchronously via the GPU pipeline. A synchronous
    /// `drawHierarchy` would capture a blank `CALayer`.
    func captureChartForEditor(_ chart: ChartData) async {
        let view = ChartRendererView(chart: chart)
        guard let image = await ViewSnapshot.capture(view, size: chartCaptureSize) else {
            showCaptureError = true
            return
        }
        capturedChartImage = IdentifiableImage(image: image)
    }

    /// Clears `capturedChartImage`, dismissing the presented `SnipEditorView`.
    func dismissEditor() {
        capturedChartImage = nil
    }
}
