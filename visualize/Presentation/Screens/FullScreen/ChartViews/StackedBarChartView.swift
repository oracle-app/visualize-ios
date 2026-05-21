//
//  StackedBarChartView.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 07/05/26.
//

import SwiftUI
import SciChart
import os.log
 
/// SciChart-based stacked column chart renderer.
/// Each key in `data` becomes one stack layer, sorted ascending by key.
/// Wraps `SCIChartSurface` in a `UIViewRepresentable` with zoom, pan,
/// and rollover tooltip modifiers for full-screen interactivity.
struct StackedBarChartView: UIViewRepresentable {
 
    // MARK: - Properties
    /// Stack key -> values per category. Keys are rendered in ascending order.
    let data: [String: [Double]]
    /// Ordered category labels for the X axis (e.g. `["0","1","2","3"]`).
    let categories: [String]
    let xLabel: String
    let yLabel: String
    var viewport: ChartViewport?
    var onCoordinatorReady: ((ChartTooltipCoordinator) -> Void)?

    // MARK: - Private
    private let stackColors: [UIColor] = [
        UIColor(Color.appTeal),
        UIColor(Color.primaryOrange),
        UIColor(Color.appNavy),
        UIColor(Color.appMint)
    ]
    
    // MARK: - Coordinator
    func makeCoordinator() -> ChartTooltipCoordinator {
        let coordinator = ChartTooltipCoordinator(xLabel: xLabel, yLabel: yLabel)

        coordinator.xValues = categories.enumerated().map { idx, cat in
            Double(cat) ?? Double(idx)
        }

        coordinator.isStackedChart = true

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
 
        // MARK: Stacked Series
        let stackedCollection = SCIVerticallyStackedColumnsCollection()
        let sortedStacks = data.sorted { $0.key < $1.key }
 
        for (stackIndex, (_, stackValues)) in sortedStacks.enumerated() {
            let xData = SCIDoubleValues()
            let yData = SCIDoubleValues()
 
            for (catIndex, category) in categories.enumerated() {
                xData.add(Double(category) ?? Double(catIndex))
                // Default to 0 if this stack has fewer values than categories
                let value: Double = catIndex < stackValues.count ? stackValues[catIndex] : 0
                yData.add(value)
            }
 
            let dataSeries = SCIXyDataSeries(xType: .double, yType: .double)
            dataSeries.append(x: xData, y: yData)
 
            let color: UIColor = stackColors[stackIndex % stackColors.count]
            let stackedSeries = SCIStackedColumnRenderableSeries()
            stackedSeries.dataSeries = dataSeries
            stackedSeries.fillBrushStyle = SCISolidBrushStyle(color: color)
            stackedSeries.strokeStyle = SCISolidPenStyle(color: .clear, thickness: 0)
            stackedSeries.dataPointWidth = 0.7
 
            stackedCollection.add(stackedSeries)
        }
 
        surface.renderableSeries.add(stackedCollection)
 
        // MARK: Interactivity
        context.coordinator.attach(to: surface)
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
    if let chart = ChartConfigParser.parse(from: MockChartJSONs.stackedBarConfig) {
        ChartRendererView(chart: chart)
            .frame(height: 400)
    }
}
