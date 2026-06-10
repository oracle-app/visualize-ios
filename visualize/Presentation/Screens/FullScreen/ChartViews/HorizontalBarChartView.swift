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
/// Individual bar colours are applied via `BarFillPaletteProvider`, cycling
/// through the active `ChartColorTheme` palette per data point.

import SwiftUI
import SciChart
import os.log

// MARK: - Palette Provider

/// Supplies a unique fill colour per data-point index, cycling through
/// the provided palette. Used to colour each horizontal bar individually
/// within a single `SCIStackedColumnRenderableSeries`.
private final class BarFillPaletteProvider: SCIPaletteProviderBase<SCIStackedColumnRenderableSeries>,
                                             ISCIFillPaletteProvider,
                                             ISCIStrokePaletteProvider {
    var fillColors = SCIUnsignedIntegerValues()
    var strokeColors = SCIUnsignedIntegerValues()

    /// ARGB codes for the palette, keyed by absolute data-point index.
    private let paletteARGB: [UInt32]
    private let clearARGB = UIColor.clear.colorARGBCode()

    init(colors: [UIColor]) {
        paletteARGB = colors.map { $0.colorARGBCode() }
        super.init(renderableSeriesType: SCIStackedColumnRenderableSeries.self)
    }

    /// Rebuilds the colour arrays on every render pass. SciChart only draws the
    /// points currently inside the viewport and reads the palette arrays by
    /// *render-pass index* (0, 1, 2 … for the visible bars). If the arrays are
    /// built once against the full dataset, zooming/panning shifts that index
    /// and the colours appear to rotate across the bars.
    ///
    /// To keep each bar's colour fixed, we read the real x-value of every
    /// visible point from the render-pass data (which equals its absolute
    /// category index) and map that back into the palette.
    override func update() {
        guard !paletteARGB.isEmpty,
              let renderPassData = renderableSeries?.currentRenderPassData else {
            return
        }

        let count = renderPassData.pointsCount
        fillColors.count = count
        strokeColors.count = count

        let xValues = (renderPassData as? SCIXyRenderPassData)?.xValues

        for renderIndex in 0..<count {
            let absoluteIndex: Int
            if let xValues = xValues, renderIndex < xValues.count {
                absoluteIndex = Int(xValues.getValueAt(renderIndex).rounded())
            } else {
                absoluteIndex = renderIndex
            }
            let paletteIndex = ((absoluteIndex % paletteARGB.count) + paletteARGB.count) % paletteARGB.count
            fillColors.set(paletteARGB[paletteIndex], at: renderIndex)
            strokeColors.set(clearARGB, at: renderIndex)
        }
    }
}

// MARK: - View

struct HorizontalBarChartView: UIViewRepresentable {

    // MARK: - Properties

    let categories: [String]
    let values: [Double]
    let xLabel: String
    let yLabel: String
    let theme: ChartColorTheme
    var viewport: ChartViewport?
    var onCoordinatorReady: ((ChartTooltipCoordinator) -> Void)?

    // MARK: - Coordinator

    func makeCoordinator() -> ChartTooltipCoordinator {
        let coordinator = ChartTooltipCoordinator(xLabel: xLabel, yLabel: yLabel)
        coordinator.xValues = categories.indices.map { Double($0) }
        coordinator.yValues = Array(values.prefix(categories.count))
        coordinator.isHorizontalChart = true
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
        xAxis.axisAlignment = .left
        xAxis.flipCoordinates = true
        xAxis.tickLabelStyle = SCIFontStyle(fontSize: 12, andTextColor: primaryColor)
        xAxis.majorGridLineStyle = SCISolidPenStyle(color: gridLineColor, thickness: 1)
        xAxis.minorGridLineStyle = SCISolidPenStyle(color: .clear, thickness: 0)
        xAxis.axisBandsStyle = SCISolidBrushStyle(color: .clear)
        xAxis.visibleRange = SCIDoubleRange(min: -0.5, max: Double(categories.count) - 0.5)

        let yAxis = SCINumericAxis()
        yAxis.axisTitle = yLabel
        yAxis.axisAlignment = .bottom
        yAxis.flipCoordinates = true
        yAxis.tickLabelStyle = SCIFontStyle(fontSize: 12, andTextColor: primaryColor)
        yAxis.majorGridLineStyle = SCISolidPenStyle(color: gridLineColor, thickness: 1)
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
        
        // MARK: Palette — cycles theme colours per bar
        let paletteColors = categories.indices.map { theme.uiColors[$0 % theme.uiColors.count] }
        
        // MARK: Series
        let stackedCollection = SCIHorizontallyStackedColumnsCollection()

        let stackedSeries = SCIStackedColumnRenderableSeries()
        stackedSeries.dataSeries = dataSeries
        stackedSeries.paletteProvider = BarFillPaletteProvider(colors: paletteColors)
        stackedSeries.dataPointWidth = 0.7

        stackedCollection.add(stackedSeries)
        surface.renderableSeries.add(stackedCollection)

        // MARK: Interactivity
        context.coordinator.attach(to: surface, zoomDirection: .xyDirection)
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
    if let chart = ChartConfigParser.parse(from: MockChartJSONs.horizontalBarConfig) {
        ChartRendererView(chart: chart)
            .frame(height: 400)
    }
}
