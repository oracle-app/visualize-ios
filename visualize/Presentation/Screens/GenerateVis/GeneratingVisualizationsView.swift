//
//  EditVisualizationView.swift
//  VisualizeApp
//
//  Created by Zuleyca Guadalupe Balles Soto on 11/04/26.
//

import SwiftUI

private enum GeneratingVisualizationsStyle {
    static let backgroundColor = Color(red: 245 / 255, green: 244 / 255, blue: 242 / 255)
    static let titleColor = Color(red: 19 / 255, green: 33 / 255, blue: 44 / 255)
    static let secondaryTextColor = Color(red: 89 / 255, green: 114 / 255, blue: 113 / 255)
    static let accentColor = Color(red: 52 / 255, green: 121 / 255, blue: 124 / 255)
    static let buttonBackgroundColor = Color.white
}

struct GeneratingVisualizationsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = GeneratingVisualizationsViewModel()

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                Spacer()

                centerContent

                Spacer()

                cancelButtonSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .fullScreenCover(isPresented: $viewModel.navigateToVizReady) {
            VizReadyView(onClose: { viewModel.dismissToUpload = true })
        }
        .onChange(of: viewModel.dismissToUpload) { _, shouldDismiss in
            if shouldDismiss { dismiss() }
        }
    }

    private var backgroundView: some View {
        Color(Color.appBackground)
            .ignoresSafeArea()
    }

    private var centerContent: some View {
        VStack(spacing: 0) {
            Text(viewModel.title)
                .font(.title.weight(.bold))
                .foregroundStyle(Color(red: 19 / 255, green: 33 / 255, blue: 44 / 255))
                .multilineTextAlignment(.center)

            Text(viewModel.message)
                .font(.body.weight(.regular))
                .foregroundStyle(Color(red: 89 / 255, green: 114 / 255, blue: 113 / 255))
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
                .foregroundStyle(Color(red: 89 / 255, green: 114 / 255, blue: 113 / 255))
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
                .foregroundStyle(Color(red: 52 / 255, green: 121 / 255, blue: 124 / 255))
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
                        .stroke(Color(red: 52 / 255, green: 121 / 255, blue: 124 / 255), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GeneratingVisualizationsView()
}
