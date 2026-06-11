//
//  FullScreenView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 24/04/26.
//
/// Full screen view for displaying a single visualization.
/// Parses the configJSON from the VisualizationCard and renders
/// the appropriate chart type via ChartRendererView.
/// Includes a header with back navigation and shared members,
/// a snipping tool button, and an error state with retry support.

import SwiftUI

struct FullScreen: View {

    // MARK: - Properties

    let card: VisualizationCard

    // MARK: - State

    @State private var viewModel: FullScreenViewModel
    @State private var threadsViewModel: ThreadScreenViewModel
    @State private var chartLoadID = UUID()
    @State private var showThreads = true
    @State private var isSnipping = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.08)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    // MARK: - Private

    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    // MARK: - Init

    init(card: VisualizationCard) {
        self.card = card
        let userDatasource = UserDatasource()
        let teamDatasource = TeamDatasource()
        let authDatasource = AuthFirebaseDatasource()
        let vizDatasource = VisualizationDatasource(
            userDatasource: userDatasource,
            teamsDatasource: teamDatasource
        )
        let storageDatasource = StorageDatasource()
        let commentDatasource = CommentDatasource()
        let authRepository = AuthRepositoryImpl(
            source: authDatasource
        )
        let userRepository = UserRepositoryImpl(
            userDatasource: userDatasource
        )
        let commentRepository = CommentRepositoryImpl(commentDatasource: commentDatasource)
        self._viewModel = State(initialValue: FullScreenViewModel(
            teamRepository: TeamRepositoryImpl(
                teamDatasource: teamDatasource,
                userDatasource: userDatasource
            ),
            visualizationRepository: VisualizationRepositoryImpl(
                userDatasource: userDatasource,
                visualizationDatasource: vizDatasource,
                teamsDatasource: teamDatasource
            ),
            authRepository: authRepository,
            userRepository: userRepository,
            uploadSnipUseCase: UploadSnipUseCase(
                snipRepository: SnipRepositoryImpl(storageDatasource: storageDatasource)
            ),
            postSnipCommentUseCase: PostSnipCommentUseCase(
                commentRepository: CommentRepositoryImpl(commentDatasource: commentDatasource)
            )
        ))
        self._threadsViewModel = State(initialValue: ThreadScreenViewModel(
            visualizationID: card.id,
            visualizationOwnerID: card.authorID,
            isPreview: false,
            repository: commentRepository,
            userRepository: userRepository,
            authRepository: authRepository,
            postCommentUseCase: PostCommentUseCase(),
            postReplyUseCase: PostReplyUseCase(),
            deleteCommentUseCase: DeleteCommentUseCase(),
            deleteReplyUseCase: DeleteReplyUseCase()
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.Brand.mint
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                FSHeaderView(
                    title: card.title,
                    members: card.allUsersSharedWith,
                    isCompact: isLandscape,
                    onBack: {
                        viewModel.tooltipCoordinator?.removeTooltip()
                        showThreads = false
                        dismiss()
                    }
                )

                // MARK: Chart + Snipping Tool
                // configJSON is fetched from Firestore on appear, not stored on the card,
                // so the feed remains lightweight. The parsed ChartData is stored in
                // viewModel.parsedChart — ChartConfigParser is never called from the body.
                ZStack(alignment: .topTrailing) {
                    Group {
                        if viewModel.isLoadingConfig {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let chart = viewModel.parsedChart {
                            if case .unsupported = chart {
                                errorState
                            } else {
                                ChartRendererView(
                                    chart: chart,
                                    onCoordinatorReady: { viewModel.tooltipCoordinator = $0 }
                                )
                                .id(chartLoadID)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .onGeometryChange(for: CGSize.self) { $0.size } action: {
                                    // Ignore zero sizes — a transient layout pass
                                    // should not overwrite a valid previous size.
                                    guard $1.width > 0, $1.height > 0 else { return }
                                    viewModel.chartCaptureSize = $1
                                }
                                .padding(.horizontal, isLandscape ? 0 : 12)
                                .padding(.top, 10)
                                .padding(.bottom, isLandscape ? 0 : 12)
                            }
                        } else {
                            errorState
                        }
                    }

                    // Snipping tool floats over the top-trailing corner of the chart
                    Button {
                        if let chart = viewModel.parsedChart {
                            viewModel.prepareChartForEditorCapture()
                            showThreads = false
                            isSnipping = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                Task { await viewModel.captureChartForEditor(chart) }
                            }
                        }
                    } label: {
                        Image(systemName: "crop")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .glassEffect(.regular.tint(AppColors.Brand.primaryOrange), in: Circle())
                    }
                    // Disabled when parsedChart is nil (not yet loaded / parse error),
                    // .unsupported (chart type not yet renderable), or when
                    // chartCaptureSize is zero (geometry value hasn't arrived yet).
                    .disabled(!viewModel.isCropEnabled)
                    .padding(.trailing, 20)
                    .padding(.top, isLandscape ? 6 : 18)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, isLandscape ? 0 : 50)
            }
        }
        .task { await viewModel.fetchConfigJSON(visualizationID: card.id) }
        .onChange(of: chartLoadID) { _, _ in
            // Reset all config state through the VM so both configJSON
            // and parsedChart are cleared atomically before the retry fetch.
            viewModel.resetConfig()
            Task { await viewModel.fetchConfigJSON(visualizationID: card.id) }
        }
        .fullScreenCover(item: $viewModel.capturedChartImage) { wrapped in
            SnipEditorScreen(
                chartImage: wrapped.image,
                onPost: { image, caption in
                    Task {
                        _ = await viewModel.uploadSnip(image, visualizationID: card.id, caption: caption)
                    }
                },
                onDismiss: {
                    viewModel.dismissEditor()
                    showThreads = true
                    isSnipping = false
                }
            )
            .preventScreenShotSilent(isActive: true)
        }
        .alert("Capture failed", isPresented: $viewModel.showCaptureError) {
            Button("OK", role: .cancel) {isSnipping = false} 
        } message: {
            Text("Could not capture the chart. Please try again.")
        }
        .preventScreenShotSilent(isActive: !isSnipping)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: Binding(
            get: { showThreads && !isLandscape },
            set: { showThreads = $0 }
        )) {
            ThreadScreen(
                visualizationID: card.id,
                visualizationOwnerID: card.authorID,
                isCollapsed: selectedDetent == .fraction(0.08),
                viewModel: threadsViewModel
            )
                .background(Color.appBackground)
                .interactiveDismissDisabled(true)
                .presentationDetents([.fraction(0.08), .medium, .large], selection: $selectedDetent)
                .presentationBackgroundInteraction(.enabled(upThrough: .large))
                .presentationCornerRadius(24)
                .presentationDragIndicator(.visible)
                .preventScreenShotSilent(isActive: !isSnipping)
        }
        .onChange(of: isLandscape) { _, newValue in
            if !newValue {
                showThreads = true
            }
        }
        .onChange(of: viewModel.snipPosted) { _, posted in
            if posted {
                Task { await threadsViewModel.appendNewComments() }
                viewModel.snipPosted = false
            }
        }
    }

    // MARK: - Private

    private var errorState: some View {
        VStack(spacing: 5) {
            Text(String(localized: "Couldn't load"))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColors.Brand.teal)
            Text(String(localized: "Something went wrong."))
                .font(.system(size: 17))
                .foregroundStyle(AppColors.Brand.teal)
                .multilineTextAlignment(.center)
            Button("Try again") {
                chartLoadID = UUID()
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 130)
            .padding(.vertical, 15)
            .background(AppColors.Brand.teal)
            .cornerRadius(296)
            .padding(.top, 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 12)
        .padding(.top, 60)
    }
}

// MARK: - Preview

#Preview("Tile") {
    FullScreen(card: VisualizationCard(
        id: "preview-id",
        title: "Relative performance of major currencies against the dollar",
        author: "Mariana Islas",
        authorID: "1",
        createdAt: Date(),
        previewJSON: testPreviewJSON,
        teamsSharedWith: [],
        usersSharedWith: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana", role: .admin),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis", role: .admin),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria", role: .admin)
        ],
        allUsersSharedWith: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana", role: .admin),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis", role: .admin),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria", role: .admin)
        ]
    ))
}

#Preview("Error - JSON inválido") {
    FullScreen(card: VisualizationCard(
        id: "preview-error",
        title: "Gráfica rota",
        author: "Mariana Islas",
        authorID: "1",
        createdAt: Date(),
        previewJSON: "{}",
        teamsSharedWith: [],
        usersSharedWith: [],
        allUsersSharedWith: []
    ))
}

let testPreviewJSON = """
{
"chartIndex": 9,
"chartName": "Survival Trend by Age",
"chartType": "Area",
"data": {
    "field1": ["0-19","20-39","40-59","60+"],
    "field2": {
        "98": ["64","164","75","16"],
        "92":     ["69","169","66","30"]œ
    }
},
"metrics": { "field1": "Age Group", "field2": "Count", "field3": "Outcome" },
"page": 0, "pageSize": 100, "preview": true,
"status": "COMPLETED", "totalPages": 1, "totalPoints": 4
}
"""
