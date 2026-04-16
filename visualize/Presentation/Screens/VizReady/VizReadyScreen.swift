//
//  VizReadyScreen.swift
//  visualize
//
//  Created by Nicolás Peralta on 15/04/26.
//

import SwiftUI

// MARK: - VizHeader

/// Sticky navigation bar for the VizReady flow.
///
/// `collapseProgress` drives the cross-fade: 0 = top (logo visible),
/// 1 = scrolled ≥ 80 pt ("Choose visualization" visible).
private struct VizHeader: View {

    let collapseProgress: Double
    let isSelectionValid: Bool
    let height: CGFloat
    let onClose: () -> Void
    let onProceed: () -> Void

    var body: some View {
        HStack {
            closeButton
            Spacer()
            centerLogo
            Spacer()
            proceedButton
        }
        .padding(.horizontal, 24)
        .frame(height: height)
        .background(navBackground)
        .overlay(alignment: .bottom) { separator }
    }

    // MARK: Subviews

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.appNavy)
                .frame(width: 48, height: 48)
                .background(Circle().fill(.ultraThinMaterial))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var centerLogo: some View {
        ZStack {
            // Oracle logo — falls back to party.popper if asset is absent
            Group {
                if UIImage(named: "OracleLogo") != nil {
                    Image("OracleLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                } else {
                    Image(systemName: "party.popper")
                        .font(.system(size: 22))
                        .foregroundStyle(.black)
                }
            }
            .opacity(1.0 - collapseProgress)
            .scaleEffect(CGFloat(1.0 - collapseProgress * 0.15), anchor: .center)

            Text("Choose visualization")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.appNavy)
                .opacity(collapseProgress)
                .scaleEffect(CGFloat(0.88 + collapseProgress * 0.12), anchor: .center)
        }
    }

    private var proceedButton: some View {
        Button(action: onProceed) {
            Image(systemName: "arrow.right")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isSelectionValid ? Color.appNavy : Color.gray.opacity(0.35))
                .frame(width: 48, height: 48)
                .background(Circle().fill(.ultraThinMaterial))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(!isSelectionValid)
    }

    private var navBackground: some View {
        ZStack {
            Color.white.opacity(0.65)
            Rectangle().fill(.ultraThinMaterial)
        }
        .ignoresSafeArea(edges: .top)
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 0.5)
            .opacity(collapseProgress)
    }
}

// MARK: - VizReadyView

struct VizReadyView: View {

    @Environment(\.dismiss) var dismiss
    @State private var viewModel = VizReadyViewModel()
    @State private var scrollOffset: CGFloat = 0

    private let navBarHeight: CGFloat = 60

    /// Normalized scroll progress: 0 at top, 1 when scrolled ≥ 80 pt.
    private var collapseProgress: Double {
        min(1.0, max(0.0, Double(scrollOffset) / 80.0))
    }

    var body: some View {
        ZStack(alignment: .top) {
            scrollContent
            VizHeader(
                collapseProgress: collapseProgress,
                isSelectionValid: viewModel.isSelectionValid,
                height: navBarHeight,
                onClose:   { dismiss() },
                onProceed: { /* conectar al coordinator/router */ }
            )
        }
        .background(Color.appBackground)
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear.frame(height: navBarHeight + 16)
                expandedHeader
                cards
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            geo.contentOffset.y
        } action: { _, newY in
            scrollOffset = max(0, newY)
        }
    }

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
            .opacity(max(0.0, 1.0 - collapseProgress * 2.0))

            Text("Choose the chart that best represents the insights you want to share")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.appSubtitle.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(max(0.0, 1.0 - collapseProgress * 2.0))
        }
    }

    private var cards: some View {
        VStack(spacing: 14) {
            ForEach(viewModel.charts.indices, id: \.self) { idx in
                RecommendedChartCard(
                    title: viewModel.charts[idx].title,
                    isSelected: viewModel.isSelected(viewModel.charts[idx].id),
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleSelection(for: viewModel.charts[idx].id)
                        }
                    },
                    onTitleChange: { newTitle in
                        viewModel.updateTitle(newTitle, forChartAt: idx)
                    }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}

// MARK: - Preview
#Preview {
    VizReadyView()
}
