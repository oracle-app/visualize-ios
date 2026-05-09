//
//  MockChartPlaceholderView.swift
//  visualize
//
//  Created by Nicolas Peralta on 09/05/26.
//

import SwiftUI

// MARK: - MockChartPlaceholderView

/// Visually obvious SwiftUI placeholder used as the capture source
/// during the mock phase (before SciChart real rendering lands).
/// Sizing is driven externally by the snapshot helper — no internal `.frame(...)`.
struct MockChartPlaceholderView: View {

    // MARK: - Body

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appMint.opacity(0.7), Color.appTeal.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                Text("MOCK CHART")
                    .font(.system(size: 32, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color.appTeal)

                // MARK: Bar Chart Paths

                GeometryReader { geo in
                    Path { path in
                        let width = geo.size.width
                        let height = geo.size.height
                        let ratios: [CGFloat] = [0.3, 0.6, 0.45, 0.8, 0.55, 0.7]
                        let barWidth = width / CGFloat(ratios.count * 2)
                        for (index, ratio) in ratios.enumerated() {
                            let xPos = CGFloat(index * 2) * barWidth + barWidth / 2
                            let barHeight = height * ratio
                            path.addRect(CGRect(
                                x: xPos,
                                y: height - barHeight,
                                width: barWidth,
                                height: barHeight
                            ))
                        }
                    }
                    .fill(Color.primaryOrange.opacity(0.85))
                }
                .frame(height: 160)
                .padding(.horizontal, 24)

                Text("Placeholder for SciChart integration")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.appTeal.opacity(0.8))
            }
            .padding()
        }
    }
}

// MARK: - Preview

#Preview {
    MockChartPlaceholderView()
        .frame(width: 800, height: 380)
}
