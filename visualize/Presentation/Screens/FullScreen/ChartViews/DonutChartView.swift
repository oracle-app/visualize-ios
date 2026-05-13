//
//  DonutChartView.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 07/05/26.
//

import SwiftUI
import SciChart
 
/// SciChart-based donut chart renderer.
///
/// Uses `SCIPieChartSurface` with `SCIDonutRenderableSeries` and a fixed hole radius.
/// Includes `SCIPieChartTooltipModifier` for interactive tooltips on tap.
struct DonutChartView: UIViewRepresentable {
 
    // MARK: - Properties
 
    let values: [Double]
    let labels: [String]
 
    // MARK: - Private
 
    private let segmentColors: [UIColor] = [
        UIColor(Color.appTeal),
        UIColor(Color.primaryOrange),
        UIColor(Color.appLightTeal),
        UIColor(Color.appMint),
        UIColor(Color.appChartGray)
    ]
 
    // MARK: - UIViewRepresentable
 
    func makeUIView(context: Context) -> SCIPieChartSurface {
        let surface = SCIPieChartSurface()
        surface.backgroundColor = UIColor(Color.white)
        surface.holeRadius = 100
        surface.holeRadiusSizingMode = .absolute
 
        let donutSeries = SCIDonutRenderableSeries()
        donutSeries.drawLabels = true
 
        for (index, value) in values.enumerated() {
            donutSeries.segmentsCollection.add(
                makeSegment(
                    value: value,
                    title: index < labels.count ? labels[index] : "",
                    color: segmentColors[index % segmentColors.count]
                )
            )
        }
 
        surface.renderableSeries.add(donutSeries)
        surface.chartModifiers.add(SCIPieChartTooltipModifier())
 
        return surface
    }
 
    func updateUIView(_ uiView: SCIPieChartSurface, context: Context) {}
 
    // MARK: - Private Helpers
 
    /// Creates a styled `SCIPieSegment` for the given value and color.
    /// - Parameters:
    ///   - value: Numeric value of the segment.
    ///   - title: Label shown on tooltip hover.
    ///   - color: Fill color for the segment.
    /// - Returns: A configured `SCIPieSegment`.
    private func makeSegment(value: Double, title: String, color: UIColor) -> SCIPieSegment {
        let segment = SCIPieSegment()
        segment.value = value
        segment.title = title
        segment.fillStyle = SCISolidBrushStyle(color: color)
        segment.strokeStyle = SCISolidPenStyle(color: UIColor(Color.white), thickness: 2)
        return segment
    }
}
 
// MARK: - Preview
#Preview {
    if let chart = ChartConfigParser.parse(from: MockChartJSONs.donutConfig) {
        ChartRendererView(chart: chart)
            .frame(height: 400)
    }
}
