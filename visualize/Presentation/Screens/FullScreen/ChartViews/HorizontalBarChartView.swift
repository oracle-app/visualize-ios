//
//  HorizontalBarChartView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 12/05/26.
//
/// SciChart-based horizontal bar chart renderer.
/// Achieved by swapping X and Y axis alignment so bars grow left-to-right.
/// X axis holds the bar lengths (values), Y axis holds the category indices.
/// Wraps SCIChartSurface in a UIViewRepresentable with zoom on Y axis,
/// and tap tooltip modifiers for full-screen interactivity.

import SwiftUI
import SciChart
import os.log

struct HorizontalBarChartView: UIViewRepresentable {

    // MARK: - Properties

    let categories: [String]
    let values: [Double]
    let xLabel: String
    let yLabel: String
    var viewport: ChartViewport?
    var onCoordinatorReady: ((ChartTooltipCoordinator) -> Void)?

    // MARK: - Coordinator

    func makeCoordinator() -> ChartTooltipCoordinator {
        let coordinator = ChartTooltipCoordinator(xLabel: xLabel, yLabel: yLabel)
        coordinator.xValues = categories.indices.map { Double($0) }
        coordinator.yValues = Array(values.prefix(categories.count))
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
        xAxis.axisAlignment = .left
        xAxis.flipCoordinates = true
        xAxis.tickLabelStyle = SCIFontStyle(fontSize: 12, andTextColor: UIColor(Color.appTeal))
        xAxis.majorGridLineStyle = SCISolidPenStyle(color: UIColor(Color.appTeal).withAlphaComponent(0.2), thickness: 1)
        xAxis.minorGridLineStyle = SCISolidPenStyle(color: .clear, thickness: 0)
        xAxis.axisBandsStyle = SCISolidBrushStyle(color: .clear)

        let yAxis = SCINumericAxis()
        yAxis.axisTitle = yLabel
        yAxis.axisAlignment = .bottom
        yAxis.flipCoordinates = true
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

        for index in categories.indices {
            guard index < values.count else { break }
            xData.add(Double(index))
            yData.add(values[index])
        }

        let dataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        dataSeries.acceptsUnsortedData = true
        dataSeries.append(x: xData, y: yData)

        // MARK: Series
        let stackedCollection = SCIHorizontallyStackedColumnsCollection()

        let stackedSeries = SCIStackedColumnRenderableSeries()
        stackedSeries.dataSeries = dataSeries
        stackedSeries.fillBrushStyle = SCISolidBrushStyle(color: UIColor(Color.appTeal))
        stackedSeries.strokeStyle = SCISolidPenStyle(color: .clear, thickness: 0)
        stackedSeries.dataPointWidth = 0.7

        stackedCollection.add(stackedSeries)
        surface.renderableSeries.add(stackedCollection)

        // MARK: Interactivity
        context.coordinator.attach(to: surface, zoomDirection: .yDirection)
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
    if let chart = ChartConfigParser.parse(from: MockChartJSONs.horizontalBarConfig) {
        ChartRendererView(chart: chart)
            .frame(height: 400)
    }
}
