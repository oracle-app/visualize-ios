//
//  EditVisualizationView.swift
//  VisualizeApp
//
//  Created by Zuleyca Guadalupe Balles Soto on 11/04/26.
//

import SwiftUI

struct GeneratingVisualizationsView: View {
    @State private var viewModel = GeneratingVisualizationsViewModel()
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        ZStack {

            VStack(spacing: 0) {
                Spacer()

                centerContent

                Spacer()

                cancelButtonSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
            .appBackground()
        }
        .task {
            guard let fileURL = coordinator.pendingFileURL else {
                viewModel.errorMessage = String(localized: "No dataset to analyze. Please go back and select a file.")
                return
            }

            await viewModel.startLoading(fileURL: fileURL)
            
            // Navigate to VizReady once suggestions are ready.
            // navigateToVizReady(with:) stores the suggestions and pushes the route in one call,
            // so the route is never pushed without its data.
            if !viewModel.suggestions.isEmpty {
                coordinator.navigateToVizReady(with: viewModel.suggestions)
            }
        }
        .portraitOrientationLock()
    }

    private var centerContent: some View {
        VStack(spacing: 0) {
            Text(viewModel.title)
                .font(.title.weight(.bold))
                .foregroundStyle(Color.primaryText)
                .multilineTextAlignment(.center)

            Text(viewModel.message)
                .font(.body.weight(.regular))
                .foregroundStyle(Color.appSubtitle)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.horizontal, 10)

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.gray)
                    .scaleEffect(1.5)
                    .padding(.top, 30)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
            }

            Text(viewModel.footerMessage)
                .font(.body.weight(.regular))
                .foregroundStyle(Color.appSubtitle)
                .multilineTextAlignment(.center)
                .padding(.top, 26)
        }
        .frame(maxWidth: 290)
    }

    private var cancelButtonSection: some View {
        Button {
            // Pop back to CreateVisualization, discarding the generating screen.
            coordinator.pop()
        } label: {
            Text("Cancel")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.appTeal)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.25),
                            radius: 4,
                            x: 0,
                            y: 2
                        )

                )
                .overlay(
                    Capsule()
                        .stroke(Color.appTeal, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GeneratingVisualizationsView()
        .environment(AppCoordinator())
}
