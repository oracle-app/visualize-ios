//
//  EditVisualizationView.swift
//  VisualizeApp
//
//  Created by Zuleyca Guadalupe Balles Soto on 11/04/26.
//

import SwiftUI

struct GeneratingVisualizationsView: View {
    @State private var viewModel = GeneratingVisualizationsViewModel()
    @Environment(\.dismiss) private var dismiss

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
        }
        .task { await viewModel.startLoading() }
        .fullScreenCover(isPresented: $viewModel.navigateToVizReady) {
            VizReadyView(onClose: { viewModel.dismissToUpload = true })
        }
        .onChange(of: viewModel.dismissToUpload) { _, shouldDismiss in
            if shouldDismiss { dismiss() }
        }
    }

    private var centerContent: some View {
        VStack(spacing: 0) {
            Text(viewModel.title)
                .font(.title.weight(.bold))
                .foregroundColor(.appNavy)
                .multilineTextAlignment(.center)

            Text(viewModel.message)
                .font(.body.weight(.regular))
                .foregroundColor(.appSubtitle)
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

            Text(viewModel.footerMessage)
                .font(.body.weight(.regular))
                .foregroundColor(.appSubtitle)
                .multilineTextAlignment(.center)
                .padding(.top, 26)
        }
        .frame(maxWidth: 290)
    }

    private var cancelButtonSection: some View {
        Button {
            viewModel.onCancelTapped()
        } label: {
            Text("Cancel")
                .font(.title3.weight(.semibold))
                .foregroundColor(.appTeal)
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
}
