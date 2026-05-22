//
//  LineChartView.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 07/05/26.
//

import SwiftUI
import SciChart
import os.log
 
/// SciChart-based line chart renderer.
/// Wraps `SCIChartSurface` in a `UIViewRepresentable` with zoom, pan,
/// and rollover tooltip modifiers for full-screen interactivity.
/// Data points are sorted by X before rendering so the line draws correctly.
struct LineChartView: UIViewRepresentable {
 
    // MARK: - Properties
    /// X->Y data points rendered in ascending X order.
    let data: [Double: Double]
    let xLabel: String
    let yLabel: String
    var viewport: ChartViewport?
    var onCoordinatorReady: ((ChartTooltipCoordinator) -> Void)?
    
    // MARK: - Coordinator
        func makeCoordinator() -> ChartTooltipCoordinator {
            let sorted = data.sorted { $0.key < $1.key }
            let coordinator = ChartTooltipCoordinator(xLabel: xLabel, yLabel: yLabel)
            coordinator.xValues = sorted.map { $0.key }
            coordinator.yValues = sorted.map { $0.value }
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
        yAxis.growBy = SCIDoubleRange(min: 0.05, max: 0.05)
 
        surface.xAxes.add(xAxis)
        surface.yAxes.add(yAxis)
 
        // MARK: Data
        // Sort ascending by X, required by SciChart for correct line drawing
        let sorted = data.sorted { $0.key < $1.key }
        let xData = SCIDoubleValues()
        let yData = SCIDoubleValues()
        sorted.forEach { xData.add($0.key); yData.add($0.value) }
 
        let dataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        dataSeries.append(x: xData, y: yData)
 
        // MARK: Series
        let renderSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = dataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: UIColor(Color.appTeal), thickness: 2)
 
        surface.renderableSeries.add(renderSeries)
 
        // MARK: Interactivity
        context.coordinator.attach(to: surface, zoomDirection: .xDirection)
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
    if let chart = ChartConfigParser.parse(from: MockChartJSONs.lineConfig) {
        ChartRendererView(chart: chart)
            .frame(height: 400)
    }
}
