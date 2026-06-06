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

    // MARK: - Config JSON State

    /// Full chart JSON fetched from Firestore on demand.
    /// `nil` while loading or after a failed fetch.
    var configJSON: String?
    /// `ChartData` parsed from `configJSON` once the fetch completes.
    /// `nil` while loading, or when the JSON is missing or malformed.
    /// `.unsupported` when the chart type is not yet renderable.
    /// The view consumes this directly — no parsing happens in the body.
    var parsedChart: ChartData?
    var isLoadingConfig: Bool = true
    /// Non-nil when the configJSON fetch or parse fails.
    var configError: String?
 
    // MARK: - Capture State

    var capturedChartImage: IdentifiableImage?
    var chartCaptureSize: CGSize = .zero
    var showCaptureError: Bool = false
    /// Reference to the live chart's coordinator, set when the chart surface attaches.
    /// Used to read the current zoom/pan viewport at capture time.
    var tooltipCoordinator: ChartTooltipCoordinator?
    /// Viewport captured before Snipping mode changes the FullScreen view tree.
    private var pendingViewport: ChartViewport?
    /// Tooltip state captured before Snipping mode changes the FullScreen view tree.
    private var pendingTooltipState: ChartTooltipCoordinator.TooltipState?

    // MARK: - Upload State

    var isUploading: Bool = false
    var uploadError: String?
    var userName: String?

    // MARK: - Dependencies

    private let teamRepository: any TeamRepository
    /// Repository used to fetch `configJSON` on demand for full-screen rendering.
    private let visualizationRepository: any VisualizationRepository
    private let authRepository: any AuthRepository
    private let userRepository: any UserRepository
    private let uploadSnipUseCase: UploadSnipUseCase
    private let postSnipCommentUseCase: PostSnipCommentUseCase
    private(set) var userID: String = ""

    // MARK: - Init

    init(
        teamRepository: any TeamRepository,
        visualizationRepository: any VisualizationRepository,
        authRepository: any AuthRepository,
        userRepository: any UserRepository,
        uploadSnipUseCase: UploadSnipUseCase,
        postSnipCommentUseCase: PostSnipCommentUseCase
    ) {
        self.teamRepository = teamRepository
        self.visualizationRepository = visualizationRepository
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.uploadSnipUseCase = uploadSnipUseCase
        self.postSnipCommentUseCase = postSnipCommentUseCase
        Task {
            await initializeUser()
        }
    }
    
    // MARK: - Auth Initialization
    private func initializeUser() async {
        do {
            self.userID = try await authRepository.getCurrentUserID()
        } catch {
            self.error = String(localized: "Could not load user session.")
        }
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

    // MARK: - Config JSON

    /// Whether the fetched chart is valid and renderable.
    /// `false` when `parsedChart` is nil or `.unsupported`.
    /// Used to gate the crop button so it is never active on an unrenderable chart.
    var isChartRenderable: Bool {
        guard let chart = parsedChart else { return false }
        if case .unsupported = chart { return false }
        return true
    }

    /// Whether the crop button should be active.
    /// Requires a renderable chart AND a valid (non-zero) capture size.
    /// Guards against the user tapping Crop before the geometry value arrives
    /// or after a transient layout pass sets `chartCaptureSize` back to `.zero`.
    var isCropEnabled: Bool {
        isChartRenderable && chartCaptureSize.width > 0 && chartCaptureSize.height > 0
    }
 
    /// Resets config state in preparation for a retry fetch.
    /// Called from the view's `onChange(of: chartLoadID)` before re-invoking `fetchConfigJSON`.
    func resetConfig() {
        configJSON = nil
        parsedChart = nil
        configError = nil
        isLoadingConfig = true
    }
 
    /// Fetches `configJSON` for the given visualization ID from Firestore and parses it
    /// into `parsedChart` immediately, so the SwiftUI body never calls the parser directly.
    ///
    /// Parsing is intentionally performed here rather than in the view body because:
    /// - The body can re-evaluate on any `@Observable` change; parsing a full JSON string
    ///   on every re-render is wasteful and runs on the main thread.
    /// - Centralizing the result in `parsedChart` lets `isChartRenderable` derive from
    ///   a single source of truth used by both the chart display and the crop button.
    ///
    /// Skips the fetch when `configJSON` is already loaded (guard prevents duplicate requests).
    /// Sets `isLoadingConfig` during the fetch and `configError` on failure or bad JSON.
    ///
    /// - Parameter visualizationID: The Firestore document ID of the visualization.
    func fetchConfigJSON(visualizationID: String) async {
        guard configJSON == nil else { return }
        isLoadingConfig = true
        configError = nil
        do {
            configJSON = try await visualizationRepository.fetchConfigJSON(visualizationID: visualizationID)
            if let json = configJSON {
                parsedChart = ChartConfigParser.parse(from: json)
                if parsedChart == nil {
                    configError = String(localized: "Chart data could not be parsed.")
                }
            } else {
                configError = String(localized: "Chart data not found.")
            }
        } catch {
            configError = error.localizedDescription
        }
        isLoadingConfig = false
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
    func prepareChartForEditorCapture() {
        pendingViewport = tooltipCoordinator?.currentViewport()
        pendingTooltipState = tooltipCoordinator?.lastTooltipState
    }

    func captureChartForEditor(_ chart: ChartData) async {
        let viewport = pendingViewport ?? tooltipCoordinator?.currentViewport()
        let tooltipState = pendingTooltipState ?? tooltipCoordinator?.lastTooltipState
        pendingViewport = nil
        pendingTooltipState = nil

        let view = ChartRendererView(
            chart: chart,
            viewport: viewport,
            onCoordinatorReady: { coordinator in
                guard let tooltipState else { return }
                // Ensure the viewport override has been applied before positioning the tooltip.
                DispatchQueue.main.async {
                    coordinator.showTooltip(from: tooltipState)
                }
            }
        )

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

    // MARK: - Upload

    /// Uploads the annotated snip to Firebase Storage and saves a Comment document in Firestore.
    /// - Parameters:
    ///   - image: The annotated snip image from `SnipEditorView`.
    ///   - visualizationID: The ID of the current visualization.
    /// - Returns: The download URL on success, `nil` on failure.
    func uploadSnip(_ image: UIImage, visualizationID: String) async -> URL? {
        isUploading = true
        uploadError = nil
        do {
            let url = try await uploadSnipUseCase.execute(
                image: image,
                userID: userID,
                visualizationID: visualizationID
            )
            let domainUser = try await userRepository.getUserByID(userID: userID)
            let name = domainUser.username
            self.userName = name
            try await postSnipCommentUseCase.execute(
                visualizationID: visualizationID,
                authorID: userID,
                imageURL: url,
                authorName: name
            )
            isUploading = false
            dismissEditor()
            return url
        } catch {
            uploadError = error.localizedDescription
            isUploading = false
            return nil
        }
    }
}
