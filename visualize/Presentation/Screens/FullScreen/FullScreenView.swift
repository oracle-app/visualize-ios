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
        self._viewModel = State(initialValue: FullScreenViewModel(
            teamRepository: TeamRepositoryImpl(
                teamDatasource: TeamDatasource(),
                userDatasource: UserDatasource()
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
                        // Implement snipping tool
                    } label: {
                        Image(systemName: "crop")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .glassEffect(.regular.tint(Color.primaryOrange), in: Circle())
                    }
                    .padding(.trailing)
                }

                // MARK: Chart
                /// This should get the complete JSON from the DB and render it, not reuse the one of VisualizationCard
                if case .unsupported = card.chart {
                    // MARK: Error State
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
                    
                } else {
                    ChartRendererView(chart: card.chart)
                        .id(chartLoadID)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(height: 380)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(.horizontal, 12)
                        .padding(.top, 10)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}

// MARK: - Preview

#Preview("Scatter") {
    FullScreenView(card: VisualizationCard(
        id: "preview-id",
        title: "Relative performance of major currencies against the dollar",
        author: "Mariana Islas",
        authorID: "1",
        createdAt: Date(),
        chart: .tile(title: "Preview", value: 100, label: "Test"), // Le pasas un dato Mock
        chartType: .tile,                                          // Le pasas el tipo Mock
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
