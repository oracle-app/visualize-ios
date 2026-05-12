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

struct FullScreenView: View {

    // MARK: - Properties

    let card: VisualizationCard

    // MARK: - State

    @State private var viewModel: FullScreenViewModel
    @State private var chartLoadID = UUID()
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    init(card: VisualizationCard) {
        self.card = card
        let userDatasource = UserDatasource()
        let teamDatasource = TeamDatasource()
        let vizDatasource = VisualizationDatasource(
            userDatasource: userDatasource,
            teamsDatasource: teamDatasource
        )
        self._viewModel = State(initialValue: FullScreenViewModel(
            teamRepository: TeamRepositoryImpl(
                teamDatasource: teamDatasource,
                userDatasource: userDatasource
            ),
            visualizationRepository: VisualizationRepositoryImpl(
                userDatasource: userDatasource,
                visualizationDatasource: vizDatasource,
                teamsDatasource: teamDatasource
            )
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appMint
                .ignoresSafeArea()
 
            VStack {
 
                // MARK: Header
                FSHeaderView(
                    title: card.title,
                    members: card.allUsersSharedWith,
                    onBack: { dismiss() }
                )

                // MARK: Snipping Tool
                HStack {
                    Spacer()
                        .frame(height: 70)
                    Button {
                        if let json = viewModel.configJSON,
                           let chart = ChartConfigParser.parse(from: json) {
                            Task { await viewModel.captureChartForEditor(chart) }
                        }
                    } label: {
                        Image(systemName: "crop")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .glassEffect(.regular.tint(Color.primaryOrange), in: Circle())
                    }
                    .disabled(viewModel.configJSON == nil)
                    .padding(.trailing)
                }

                // MARK: Chart
                // configJSON is fetched from Firestore on appear, not stored on the card, so the feed remains lightweight.
                Group {
                    if viewModel.isLoadingConfig {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(height: 380)
                    } else if let json = viewModel.configJSON,
                              let parsedChart = ChartConfigParser.parse(from: json) {
                        if case .unsupported = parsedChart {
                            errorState
                        } else {
                            ChartRendererView(chart: parsedChart)
                                .id(chartLoadID)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .frame(height: 380)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .padding(.horizontal, 12)
                                .padding(.top, 10)
                        }
                    } else {
                        errorState
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task { await viewModel.fetchConfigJSON(visualizationID: card.id) }
        .onChange(of: chartLoadID) { _, _ in
            // Reset configJSON so fetchConfigJSON runs again on retry
            viewModel.configJSON = nil
            Task { await viewModel.fetchConfigJSON(visualizationID: card.id) }
        }
        .fullScreenCover(item: $viewModel.capturedChartImage) { wrapped in
            SnipEditorView(
                chartImage: wrapped.image,
                onPost: { _ in
                    print("[FullScreen] SnipEditor onPost stub — image discarded")
                    viewModel.dismissEditor()
                },
                onDismiss: {
                    viewModel.dismissEditor()
                }
            )
        }
        .alert("Capture failed", isPresented: $viewModel.showCaptureError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Could not capture the chart. Please try again.")
        }
        .preventScreenShot()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
 
    // MARK: - Private
 
    private var errorState: some View {
        VStack(spacing: 5) {
            Text("Couldn't load")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.appTeal)
            Text("Something went wrong.")
                .font(.system(size: 17))
                .foregroundStyle(Color.appTeal)
                .multilineTextAlignment(.center)
            Button("Try again") {
                chartLoadID = UUID()
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 130)
            .padding(.vertical, 15)
            .background(Color.appTeal)
            .cornerRadius(296)
            .padding(.top, 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 380)
        .padding(.horizontal, 12)
        .padding(.top, 60)
    }
}

// MARK: - Preview

#Preview("Scatter") {
    FullScreenView(card: VisualizationCard(
        id: "preview-id",
        title: "Relative performance of major currencies against the dollar",
        author: "Mariana Islas",
        authorID: "1",
        createdAt: Date(),
        chart: .tile(title: "Preview", value: 100, label: "Test"),
        chartType: .tile,
        teamsSharedWith: [],
        usersSharedWith: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana"),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis"),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria")
        ],
        allUsersSharedWith: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana"),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis"),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria")
        ]
    ))
}

#Preview("Error - JSON inválido") {
    FullScreenView(card: VisualizationCard(
        id: "preview-error",
        title: "Gráfica rota",
        author: "Mariana Islas",
        authorID: "1",
        createdAt: Date(),
        chart: .unsupported(type: "Invalid JSON"),
        chartType: .tile,
        teamsSharedWith: [],
        usersSharedWith: [],
        allUsersSharedWith: []
    ))
}
