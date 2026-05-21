//
//  ThreadsPreviewImageContainer.swift
//  visualize
//
//  Created by Ruben Castro on 20/05/26.
//
//  Container that displays the edited visualization inside the Threads
//  Preview screen, with explicit handling for the three image edge cases
//  called out in the ticket:
//  - Loading state (slow image rendering)
//  - Failed state (image fails to load)
//  - Loaded state (the happy path coming straight from SnipEditorView)
//
//  Layout follows the design: a short "Preview of the edited visualization"
//  caption above the image, the image itself centered and aspect-fit so
//  large image dimensions never break the layout.

import SwiftUI

struct ThreadsPreviewImageContainer: View {

    // MARK: - Properties

    /// The edited image exported from `SnipEditorView`. Optional so the
    /// container can render the failure state without a value.
    let image: UIImage?
    let state: ImageLoadState

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            Text("Preview of the edited visualization")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appNavy)
                .frame(maxWidth: .infinity, alignment: .center)

            content
                .frame(maxWidth: .infinity)
                .frame(minHeight: 220)
                .background(Color.appBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Private views

    /// Branches on `state` so the container behaves correctly for every
    /// edge case listed in the ticket. Kept as a `@ViewBuilder` rather than
    /// three separate views because the surrounding chrome (background,
    /// border, sizing) is identical for all three states.
    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            loadingState
        case .failed:
            failedState
        case .loaded:
            if let image {
                Image(uiImage: image)
                    .resizable()
                    // `scaledToFit` is intentional: large image dimensions
                    // (one of the listed edge cases) should never push the
                    // layout off-screen — the image shrinks instead.
                    .scaledToFit()
                    .padding(8)
            } else {
                // Defensive: state says `.loaded` but no image was provided.
                // Treat it as a failure so the user gets a clear signal
                // instead of an empty container.
                failedState
            }
        }
    }

    private var loadingState: some View {
        VStack(spacing: 10) {
            ProgressView()
                .controlSize(.regular)
                .tint(Color.appTeal)
            Text("Loading preview…")
                .font(.system(size: 13))
                .foregroundStyle(Color.appSubtitle)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }

    private var failedState: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(Color.appTeal)
            Text("Couldn't load preview")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.appNavy)
            Text("The edited visualization failed to load.")
                .font(.system(size: 13))
                .foregroundStyle(Color.appSubtitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }
}

// MARK: - Preview

#Preview("Loaded") {
    ThreadsPreviewImageContainer(image: UIImage(systemName: "chart.xyaxis.line"), state: .loaded)
        .padding()
        .background(Color.appBackground)
}

#Preview("Loading") {
    ThreadsPreviewImageContainer(image: nil, state: .loading)
        .padding()
        .background(Color.appBackground)
}

#Preview("Failed") {
    ThreadsPreviewImageContainer(image: nil, state: .failed)
        .padding()
        .background(Color.appBackground)
}
