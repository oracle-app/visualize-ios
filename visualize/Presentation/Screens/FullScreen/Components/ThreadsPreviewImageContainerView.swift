//
//  ThreadsPreviewImageContainer.swift
//  visualize
//
//  Created by Ruben Castro on 20/05/26.
//
//  Container that displays the edited visualization inside the Threads
//  Preview screen. The previous version exposed a three-state load machine
//  (`loading` / `loaded` / `failed`) but nothing in the flow ever drove the
//  state away from `.loaded`, so the gating was theatre. The component now
//  branches on a simple optional: an image is rendered when present, and a
//  failure layout is rendered when the caller supplies `nil`. Large image
//  dimensions are handled by `scaledToFit` so they cannot break the layout.

import SwiftUI

struct ThreadsPreviewImageContainerView: View {

    // MARK: - Properties

    /// The edited image exported from `SnipEditorView`. Optional so the
    /// container can render the failure state without a value.
    let image: UIImage?

    // Dynamic Type-aware sizing for the header label.
    @ScaledMetric(relativeTo: .footnote) private var headerFontSize: CGFloat = 13
    @ScaledMetric(relativeTo: .body) private var minContainerHeight: CGFloat = 220

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            Text(String(localized: "Preview of the edited visualization"))
                .font(.system(size: headerFontSize, weight: .semibold))
                .foregroundStyle(Color.appNavy)
                .frame(maxWidth: .infinity, alignment: .center)

            content
                .frame(maxWidth: .infinity)
                .frame(minHeight: minContainerHeight)
                .background(Color.appBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Private views

    /// Renders the image when present, or a failure layout when `nil`.
    /// Wrapped in `@ViewBuilder` because the surrounding chrome (background,
    /// sizing) is identical for both states.
    @ViewBuilder
    private var content: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                // `scaledToFit` is intentional: large image dimensions
                // (one of the listed edge cases) should never push the
                // layout off-screen — the image shrinks instead.
                .scaledToFit()
                .padding(8)
                .accessibilityLabel("Preview of the edited visualization")
        } else {
            failedState
        }
    }

    private var failedState: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(Color.appTeal)
            Text(String(localized: "Couldn't load preview"))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.appNavy)
            Text(String(localized: "The edited visualization failed to load."))
                .font(.system(size: 13))
                .foregroundStyle(Color.appSubtitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, minHeight: minContainerHeight)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview("Loaded") {
    ThreadsPreviewImageContainerView(image: UIImage(systemName: "chart.xyaxis.line"))
        .padding()
        .background(Color.appBackground)
}

#Preview("Failed") {
    ThreadsPreviewImageContainerView(image: nil)
        .padding()
        .background(Color.appBackground)
}
