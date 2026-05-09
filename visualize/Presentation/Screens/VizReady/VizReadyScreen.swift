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

    // MARK: - State properties

    /// Called after the close button dismisses this view, so the caller can
    /// chain further dismissals up the navigation stack.
    var onClose: (() -> Void)?
    /// Dismisses this fullScreenCover.
    @Environment(\.dismiss) var dismiss
    /// Backing state machine for chart selection and title editing.
    @State private var viewModel = VizReadyViewModel()
    /// Controls presentation of the share sheet after the user taps proceed.
    @State private var showShareSheet = false
    @State private var sheetSize: PresentationDetent = .fraction(0.28)

    private let userDatasource = UserDatasource()
    private let teamDatasource = TeamDatasource()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    expandedHeader
                    cards
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: { dismiss(); onClose?() },
                        label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.appNavy)
                        }
                    )
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
                NavigationStack {
                    ShareSheet(
                        viewModel: ShareSheetViewModel(
                            teamRepository: TeamRepositoryImpl(
                                teamDatasource: teamDatasource,
                                userDatasource: userDatasource
                            ),
                            userRepository: UserRepositoryImpl(userDatasource: userDatasource)
                        ),
                        sheetSize: $sheetSize
                    )
                }
                .presentationDetents(
                    [.fraction(0.34), .large],
                    selection: $sheetSize)
                .presentationBackground(.clear)
            }
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
            ForEach(viewModel.charts) { chart in
                RecommendedChartCard(
                    title: chart.title,
                    isSelected: viewModel.isSelected(chart.id),
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleSelection(for: chart.id)
                        }
                    },
                    onTitleChange: { newTitle in
                        viewModel.updateTitle(newTitle, forID: chart.id)
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
}

// MARK: - Preview
#if DEBUG
#Preview {
    VizReadyView()
}
#endif
