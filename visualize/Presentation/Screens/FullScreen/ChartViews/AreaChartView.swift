//
//  AreaChartView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 12/05/26.
//
/// SciChart-based area chart renderer.
/// Wraps SCIChartSurface in a UIViewRepresentable with zoom, pan,
/// and tap tooltip modifiers for full-screen interactivity.
/// Data points are sorted by X before rendering so the area draws correctly.

import SwiftUI
import SciChart
import os.log

struct AreaChartView: UIViewRepresentable {

    // MARK: - Properties

    /// Ordered category labels for the X axis (e.g. ["0-9", "10-19"]).
    let categories: [String]
    /// Series name -> values per category (e.g. ["Survived": [38, 26, ...], "Died": [24, 45, ...]]).
    let series: [String: [Double]]
    let xLabel: String
    let yLabel: String
    let theme: ChartColorTheme
    var viewport: ChartViewport?
    var onCoordinatorReady: ((ChartTooltipCoordinator) -> Void)?

    // MARK: - Coordinator

    func makeCoordinator() -> ChartTooltipCoordinator {
        let coordinator = ChartTooltipCoordinator(xLabel: xLabel, yLabel: yLabel)
        coordinator.xValues = categories.indices.map { Double($0) }
        coordinator.yValues = series.sorted { $0.key < $1.key }.first?.value ?? []
        coordinator.isStackedChart = true
        return coordinator
    }

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> SCIChartSurface {
        let surface = SCIChartSurface()
        surface.backgroundColor = UIColor(Color.white)
        surface.renderableSeriesAreaBorderStyle = SCISolidPenStyle(color: .clear, thickness: 0)
        
        let primaryColor = theme.uiColors[0]
        let gridLineColor = primaryColor.withAlphaComponent(0.2)

        // MARK: Axes
        let xAxis = SCINumericAxis()
        xAxis.axisTitle = xLabel
        xAxis.tickLabelStyle = SCIFontStyle(fontSize: 12, andTextColor: primaryColor)
        xAxis.majorGridLineStyle = SCISolidPenStyle(color: gridLineColor, thickness: 1)
        xAxis.minorGridLineStyle = SCISolidPenStyle(color: .clear, thickness: 0)
        xAxis.axisBandsStyle = SCISolidBrushStyle(color: .clear)

        let yAxis = SCINumericAxis()
        yAxis.axisTitle = yLabel
        yAxis.tickLabelStyle = SCIFontStyle(fontSize: 12, andTextColor: primaryColor)
        yAxis.majorGridLineStyle = SCISolidPenStyle(color: gridLineColor, thickness: 1)
        yAxis.minorGridLineStyle = SCISolidPenStyle(color: .clear, thickness: 0)
        yAxis.axisBandsStyle = SCISolidBrushStyle(color: .clear)
        yAxis.growBy = SCIDoubleRange(min: 0.05, max: 0.1)

        surface.xAxes.add(xAxis)
        surface.yAxes.add(yAxis)

        // MARK: Data
        let sortedSeries = series.sorted { $0.key < $1.key }
        let themeColors = theme.uiColors

        for (seriesIndex, (_, values)) in sortedSeries.enumerated() {
            let xData = SCIDoubleValues()
            let yData = SCIDoubleValues()

            for (catIndex, value) in values.enumerated() {
                xData.add(Double(catIndex))
                yData.add(value)
            }

            let dataSeries = SCIXyDataSeries(xType: .double, yType: .double)
            dataSeries.append(x: xData, y: yData)

            // MARK: Series
            let color = themeColors[seriesIndex % themeColors.count]
            let renderSeries = SCIFastMountainRenderableSeries()
            renderSeries.dataSeries = dataSeries
            renderSeries.strokeStyle = SCISolidPenStyle(color: color, thickness: 2)
            renderSeries.areaStyle = SCISolidBrushStyle(color: color.withAlphaComponent(0.3))
            surface.renderableSeries.add(renderSeries)
        }

        // MARK: Interactivity
        context.coordinator.attach(to: surface)
        onCoordinatorReady?(context.coordinator)

        // MARK: Viewport override
        surface.applyViewport(viewport)

        return surface
    }

    func updateUIView(_ uiView: SCIChartSurface, context: Context) {}
    
    static func dismantleUIView(_ uiView: SCIChartSurface, coordinator: ChartTooltipCoordinator) {
        coordinator.cleanup()
    }
}

// MARK: - Preview
#Preview {
    if let chart = ChartConfigParser.parse(from: MockChartJSONs.areaConfig) {
        ChartRendererView(chart: chart)
            .frame(height: 400)
    }
}
