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

struct AreaChartView: UIViewRepresentable {

    // MARK: - Properties

    /// Ordered category labels for the X axis (e.g. ["0-9", "10-19"]).
    let categories: [String]
    /// Series name -> values per category (e.g. ["Survived": [38, 26, ...], "Died": [24, 45, ...]]).
    let series: [String: [Double]]
    let xLabel: String
    let yLabel: String

    // MARK: - Private

    private let seriesColors: [UIColor] = [
        UIColor(Color.appTeal),
        UIColor(Color.primaryOrange),
        UIColor(Color.appNavy),
        UIColor(Color.appMint)
    ]

    // MARK: - Coordinator

    func makeCoordinator() -> ChartTooltipCoordinator {
        let coordinator = ChartTooltipCoordinator(xLabel: xLabel, yLabel: yLabel)
        coordinator.xValues = categories.enumerated().map { idx, _ in Double(idx) }
        // yValues del primer series como referencia
        coordinator.yValues = series.sorted { $0.key < $1.key }.first?.value ?? []
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
        yAxis.growBy = SCIDoubleRange(min: 0.05, max: 0.1)

        surface.xAxes.add(xAxis)
        surface.yAxes.add(yAxis)

        // MARK: Data
        let sortedSeries = series.sorted { $0.key < $1.key }

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
            let color = seriesColors[seriesIndex % seriesColors.count]
            let renderSeries = SCIFastMountainRenderableSeries()
            renderSeries.dataSeries = dataSeries
            renderSeries.strokeStyle = SCISolidPenStyle(color: color, thickness: 2)
            renderSeries.areaStyle = SCISolidBrushStyle(color: color.withAlphaComponent(0.3))
            surface.renderableSeries.add(renderSeries)
        }

        // MARK: Interactivity
        context.coordinator.attach(to: surface)

        return surface
    }

    func updateUIView(_ uiView: SCIChartSurface, context: Context) {}
}

// MARK: - Preview
#Preview {
    if let chart = ChartConfigParser.parse(from: MockChartJSONs.areaConfig) {
        ChartRendererView(chart: chart)
            .frame(height: 400)
    }
}
