//
//  VerticalBarChartView.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 07/05/26.
//

import SwiftUI
import SciChart
import os.log
 
/// SciChart-based vertical bar (column) chart renderer.
/// Wraps `SCIChartSurface` in a `UIViewRepresentable` with zoom, pan,
/// and rollover tooltip modifiers for full-screen interactivity.
struct VerticalBarChartView: UIViewRepresentable {
 
    // MARK: - Properties
    /// Ordered category labels for the X axis (e.g. `["1", "2", "3"]`).
    let categories: [String]
    /// Y values in the same order as `categories`.
    let values: [Double]
    let xLabel: String
    let yLabel: String
    var viewport: ChartViewport? = nil
    var onCoordinatorReady: ((ChartTooltipCoordinator) -> Void)? = nil
    // MARK: - Coordinator
    func makeCoordinator() -> ChartTooltipCoordinator {
        let coordinator = ChartTooltipCoordinator(xLabel: xLabel, yLabel: yLabel)
        coordinator.xValues = categories.enumerated().map { idx, cat in Double(cat) ?? Double(idx) }
        coordinator.yValues = values
        return coordinator
    }
 
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> SCIChartSurface {
        let surface = SCIChartSurface()
        surface.backgroundColor = UIColor(Color.white)
        surface.renderableSeriesAreaBorderStyle = SCISolidPenStyle(color: .clear, thickness: 0)
 
        // MARK: Axes
        let xAxis = SCINumericAxis()
        xAxis.axisTitle = xLabel
        xAxis.tickLabelStyle = SCIFontStyle(fontSize: 12, andTextColor: UIColor(Color.appTeal))
        xAxis.majorGridLineStyle = SCISolidPenStyle(color: UIColor(Color.appTeal).withAlphaComponent(0.2), thickness: 1)
        xAxis.minorGridLineStyle = SCISolidPenStyle(color: .clear, thickness: 0)
        xAxis.axisBandsStyle = SCISolidBrushStyle(color: .clear)
 
        let yAxis = SCINumericAxis()
        yAxis.axisTitle = yLabel
        yAxis.tickLabelStyle = SCIFontStyle(fontSize: 12, andTextColor: UIColor(Color.appTeal))
        yAxis.majorGridLineStyle = SCISolidPenStyle(color: UIColor(Color.appTeal).withAlphaComponent(0.2), thickness: 1)
        yAxis.minorGridLineStyle = SCISolidPenStyle(color: .clear, thickness: 0)
        yAxis.axisBandsStyle = SCISolidBrushStyle(color: .clear)
        yAxis.growBy = SCIDoubleRange(min: 0, max: 0.1)
 
        surface.xAxes.add(xAxis)
        surface.yAxes.add(yAxis)
 
        // MARK: Data
        let xData = SCIDoubleValues()
        let yData = SCIDoubleValues()
        for (index, category) in categories.enumerated() {
            // Use the numeric value of the category string as X, or its index as fallback
            xData.add(Double(category) ?? Double(index))
            yData.add(values[index])
        }
 
        let dataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        dataSeries.append(x: xData, y: yData)
 
        // MARK: Series
        let renderSeries = SCIFastColumnRenderableSeries()
        renderSeries.dataSeries = dataSeries
        renderSeries.fillBrushStyle = SCISolidBrushStyle(color: UIColor(Color.appTeal))
        renderSeries.strokeStyle = SCISolidPenStyle(color: UIColor(Color.appNavy), thickness: 0.5)
        renderSeries.dataPointWidth = 0.7
 
        surface.renderableSeries.add(renderSeries)
 
        // MARK: Interactivity
        context.coordinator.attach(to: surface, zoomDirection: .xDirection,  pinchDirection: .xDirection)
        onCoordinatorReady?(context.coordinator)

        // MARK: Viewport override
        surface.applyViewport(viewport)

        return surface
    }
 
    func updateUIView(_ uiView: SCIChartSurface, context: Context) {}
    
    static func dismantleUIView(_ uiView: SCIChartSurface, coordinator: ChartTooltipCoordinator) {
        uiView.suspendUpdates()
        uiView.renderableSeries.clear()
        uiView.chartModifiers.clear()
        uiView.xAxes.clear()
        uiView.yAxes.clear()
        uiView.annotations.clear()
        coordinator.cleanup()
    }
}
 
// MARK: - Preview
#Preview {
    if let chart = ChartConfigParser.parse(from: MockChartJSONs.verticalBarConfig) {
        ChartRendererView(chart: chart)
            .frame(height: 400)
    }
}
