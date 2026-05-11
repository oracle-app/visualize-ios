//
//  PieChartView.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 07/05/26.
//

import SwiftUI
import SciChart
 
/// SciChart-based pie chart renderer.
///
/// Uses `SCIPieChartSurface`  with `SCIPieChartTooltipModifier`
/// for interactive tooltips on tap.
struct PieChartView: UIViewRepresentable {
 
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
 
        let pieSeries = SCIPieRenderableSeries()
        pieSeries.drawLabels = true
 
        for (index, value) in values.enumerated() {
            pieSeries.segmentsCollection.add(
                makeSegment(
                    value: value,
                    title: index < labels.count ? labels[index] : "",
                    color: segmentColors[index % segmentColors.count]
                )
            )
        }
 
        surface.renderableSeries.add(pieSeries)
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
    if let chart = ChartConfigParser.parse(from: MockChartJSONs.pieConfig) {
        ChartRendererView(chart: chart)
            .frame(height: 400)
    }
}
