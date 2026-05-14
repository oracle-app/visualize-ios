//
//  VizReadyScreen.swift
//  visualize
//
//  Created by Nicolás Peralta on 15/04/26.
//

import SwiftUI
 
// MARK: - VizReadyView
 
/// Full-screen view that presents AI-generated chart suggestions and lets
/// the user pick one before proceeding to the next step.
struct VizReadyView: View {
 
    // MARK: - State
 
    @Environment(AppCoordinator.self) private var coordinator
    /// Backing state machine for chart selection and title editing.
    @State private var viewModel: VizReadyViewModel
    /// Controls presentation of the share sheet after the user taps proceed.
    @State private var showShareSheet: Bool = false
    @State private var sheetSize: PresentationDetent = .fraction(0.28)
    /// Controls the discard confirmation alert triggered by the X button.
    @State private var showDiscardAlert: Bool = false
 
    private let userDatasource: UserDatasource = UserDatasource()
    private let teamDatasource: TeamDatasource = TeamDatasource()
 
    // MARK: - Init
 
    /// - Parameter suggestions: Chart suggestions produced by the ML service (or mock).
    init(suggestions: [ChartSuggestion]) {
        self._viewModel = State(initialValue: VizReadyViewModel(suggestions: suggestions))
    }
 
    // MARK: - Body
 
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                expandedHeader
                cards
            }
        }
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: { showDiscardAlert = true },
                    label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.appNavy)
                    }
                )
                .alert("Discard generated visualizations?", isPresented: $showDiscardAlert) {
                    Button("Discard", role: .destructive) {
                        // Clear the create tab stack, returning to CreateVisualization.
                        coordinator.popToRoot()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will discard your generated visualizations and return you to the dataset upload screen.")
                }
            }
            ToolbarItem(placement: .principal) {
                Group {
                    if UIImage(named: "OracleLogo") != nil {
                        Image("OracleLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                    } else {
                        Text("Choose visualization")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appNavy)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: { showShareSheet = true },
                    label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(
                                viewModel.isSelectionValid
                                    ? Color.appNavy
                                    : Color.gray.opacity(0.35)
                            )
                    }
                )
                .disabled(!viewModel.isSelectionValid)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            shareSheet
        }
    }
 
    // MARK: - Private views
 
    /// Expanded header shown at the top of the list.
    private var expandedHeader: some View {
        VStack(spacing: 8) {
            VStack(spacing: 8) {
                Text("Your visualizations are ready!")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(Color.appNavy)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
 
                Text("We've generated several charts based\non your dataset.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.appSubtitle)
                    .multilineTextAlignment(.center)
                    .tracking(-0.31)
                    .lineSpacing(7)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
 
            Text("Choose the chart that best represents the insights you want to share")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.appSubtitle.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
    }

    /// Vertically stacked list of selectable chart recommendation cards.
    private var cards: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.suggestions) { suggestion in
                RecommendedChartCard(
                    title: viewModel.displayTitle(for: suggestion),
                    chart: suggestion.chart,
                    isSelected: viewModel.isSelected(suggestion.id),
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleSelection(for: suggestion.id)
                        }
                    },
                    onTitleChange: { newTitle in
                        viewModel.updateTitle(newTitle, forID: suggestion.id)
                    }
                )
            }
 
            if let error = viewModel.titleValidationError {
                Text(error)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            }
        }
    }
 
    /// Builds the ShareSheet with the selected chart's title, configJSON, and previewJSON.
    /// Falls back to empty strings if no suggestion is selected, the proceed button
    /// is always disabled when there is no selection, so this path never reaches Firestore.
    /// On successful save, clears the create tab stack and switches to the feed tab.
    private var shareSheet: some View {
        let vizDatasource = VisualizationDatasource(
            userDatasource: userDatasource,
            teamsDatasource: teamDatasource
        )
        let vizRepository = VisualizationRepositoryImpl(
            userDatasource: userDatasource,
            visualizationDatasource: vizDatasource,
            teamsDatasource: teamDatasource
        )
        let suggestion = viewModel.selectedSuggestion
 
        return NavigationStack {
            ShareSheet(
                viewModel: ShareSheetViewModel(
                    teamRepository: TeamRepositoryImpl(
                        teamDatasource: teamDatasource,
                        userDatasource: userDatasource
                    ),
                    userRepository: UserRepositoryImpl(userDatasource: userDatasource),
                    createVisualizationUseCase: CreateVisualizationUseCase(
                        visualizationRepository: vizRepository
                    ),
                    chartTitle: suggestion.map { viewModel.displayTitle(for: $0) } ?? "",
                    chartConfigJSON: suggestion?.configJSON ?? "",
                    chartPreviewJSON: suggestion?.previewJSON ?? ""
                ),
                sheetSize: $sheetSize,
                // Clear the create tab stack and land on the feed tab.
                // popToRoot() removes generatingVisualizations + vizReady from createPath.
                // selectedTab = .feed switches the visible tab without touching feedPath.
                onConfirm: {
                    coordinator.popToRoot()
                    coordinator.selectedTab = .feed
                }
            )
        }
        .presentationDetents([.fraction(0.34), .large], selection: $sheetSize)
        .presentationBackground(.clear)
    }
}
 
// MARK: - Preview
 
#if DEBUG
#Preview {
    NavigationStack {
        VizReadyView(suggestions: [
            ChartSuggestion(
                id: 0,
                name: "Survival Rate by Passenger Class",
                chartType: .verticalBar,
                chart: .verticalBar(
                    title: "Survival Rate by Passenger Class",
                    data: ["1": 136, "2": 87, "3": 119],
                    fieldNames: ["Pclass", "Survived"]
                ),
                previewJSON: MockChartJSONs.verticalBarPreview,
                configJSON: MockChartJSONs.verticalBarConfig
            )
        ])
    }
    .environment(AppCoordinator())
}
#endif
