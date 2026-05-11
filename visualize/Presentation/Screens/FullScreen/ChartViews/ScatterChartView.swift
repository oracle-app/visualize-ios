//
//  ScatterChartView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 04/05/26.
//
/// SciChart-based scatter plot renderer.
/// Wraps SCIChartSurface in a UIViewRepresentable to display
/// X/Y data points with zoom, pan, and rollover tooltip support.

import SwiftUI
import SciChart

struct ScatterChartView: UIViewRepresentable {

    // MARK: - Properties

    let xValues: [Double]
    let yValues: [Double]
    let xLabel: String
    let yLabel: String

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> SCIChartSurface {
        let surface = SCIChartSurface()
        //SCIThemeManager.applyTheme(SCIChartTheme.expressionLight, to: surface)
        surface.backgroundColor = UIColor(Color.white)
        surface.renderableSeriesAreaBorderStyle = SCISolidPenStyle(color: .clear, thickness: 0)

        // MARK: Axes
        let xAxis = SCINumericAxis()
        xAxis.axisTitle = xLabel
        xAxis.tickLabelStyle = SCIFontStyle(fontSize: 12, andTextColor: UIColor(Color.appTeal))
        xAxis.majorGridLineStyle = SCISolidPenStyle(color: UIColor(Color.appTeal).withAlphaComponent(0.5), thickness: 1.5)
        xAxis.minorGridLineStyle = SCISolidPenStyle(color: .clear, thickness: 0)
        xAxis.axisBandsStyle = SCISolidBrushStyle(color: .clear)

        let yAxis = SCINumericAxis()
        yAxis.axisTitle = yLabel
        yAxis.tickLabelStyle = SCIFontStyle(fontSize: 12, andTextColor: UIColor(Color.appTeal))
        yAxis.visibleRange = SCIDoubleRange(min: -0.5, max: 1.5)
        yAxis.majorGridLineStyle = SCISolidPenStyle(color: UIColor(Color.appTeal).withAlphaComponent(0.5), thickness: 1.5)
        yAxis.minorGridLineStyle = SCISolidPenStyle(color: .clear, thickness: 0)
        yAxis.axisBandsStyle = SCISolidBrushStyle(color: .clear)

        surface.xAxes.add(xAxis)
        surface.yAxes.add(yAxis)

        // MARK: Data
        let xData = SCIDoubleValues()
        let yData = SCIDoubleValues()
        for (xValue, yValue) in zip(xValues, yValues) {
            xData.add(xValue)
            yData.add(yValue)
        }

        let dataSeries = SCIXyDataSeries(xType: .double, yType: .double)
        dataSeries.acceptsUnsortedData = true
        dataSeries.append(x: xData, y: yData)

        // MARK: Series
        let renderSeries = SCIXyScatterRenderableSeries()
        renderSeries.dataSeries = dataSeries
        renderSeries.pointMarker = {
            let marker = SCIEllipsePointMarker()
            marker.size = CGSize(width: 8, height: 8)
            marker.fillStyle = SCISolidBrushStyle(color: UIColor(Color.primaryOrange))
            marker.strokeStyle = SCISolidPenStyle(color: UIColor(Color.appNavy), thickness: 1.5)
            return marker
        }()

        surface.renderableSeries.add(renderSeries)

        // MARK: Interactivity
        let zoomPan = SCIZoomPanModifier()
        zoomPan.direction = .xyDirection

        let pinchZoom = SCIPinchZoomModifier()
        pinchZoom.direction = .xyDirection

        let rollover = SCIRolloverModifier()
        rollover.showTooltip = true

        let modifierGroup = SCIModifierGroup(childModifiers: [
            zoomPan,
            pinchZoom,
            SCIZoomExtentsModifier(),
            rollover
        ])

        surface.chartModifiers.add(modifierGroup)

        return surface
    }

    func updateUIView(_ uiView: SCIChartSurface, context: Context) {}
}

// MARK: - Preview

#Preview {
    if let chart = ChartConfigParser.parse(from: MockChartJSONs.scatterConfig) {
        ChartRendererView(chart: chart)
            .frame(height: 400)
    }
}
