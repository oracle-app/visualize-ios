//
//  ChartTooltipCoordinator.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 12/05/26.
//

import UIKit
import SciChart

class ChartTooltipCoordinator: NSObject {

    // MARK: - Properties

    weak var surface: SCIChartSurface?
    var tooltipLabel: UILabel?
    let xLabel: String
    let yLabel: String
    var xValues: [Double] = []
    var yValues: [Double] = []
    var isStackedChart: Bool = false

    // MARK: - Init

    init(xLabel: String, yLabel: String) {
        self.xLabel = xLabel
        self.yLabel = yLabel
    }

    // MARK: - Tap Handler

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let surface,
              let seriesArea = surface.renderableSeriesArea as? UIView
        else { return }

        let location = gesture.location(in: seriesArea)

        for index in 0..<surface.renderableSeries.count {
            guard let series = surface.renderableSeries.item(at: index) as? ISCIRenderableSeries
            else { continue }

            let hitTestInfo = SCIHitTestInfo()
            series.hitTest(hitTestInfo, at: location)

            if hitTestInfo.isHit {
                removeTooltip()

                // MARK: Hit Detection

                if isStackedChart {
                    guard
                        let xAxis = surface.xAxes.item(at: 0) as? SCINumericAxis,
                        let yAxis = surface.yAxes.item(at: 0) as? SCINumericAxis
                    else { return }

                    let xCalc = xAxis.currentCoordinateCalculator
                    let yCalc = yAxis.currentCoordinateCalculator

                    let pointIndex = Int(hitTestInfo.pointSeriesIndex)
                    let xValue = pointIndex >= 0 && pointIndex < xValues.count
                        ? xValues[pointIndex]
                        : xCalc.getDataValue(Float(hitTestInfo.hitTestPoint.x))
                    let yValue = yCalc.getDataValue(Float(hitTestInfo.hitTestPoint.y))

                    showTooltip(
                        at: gesture.location(in: surface),
                        xValue: xValue,
                        yValue: yValue,
                        on: surface
                    )
                } else {
                    let pointIndex = Int(hitTestInfo.pointSeriesIndex)
                    guard pointIndex >= 0 && pointIndex < xValues.count else { return }

                    showTooltip(
                        at: gesture.location(in: surface),
                        xValue: xValues[pointIndex],
                        yValue: yValues[pointIndex],
                        on: surface
                    )
                }
                return
            }
        }

        removeTooltip()
    }

    // MARK: - Tooltip

    func showTooltip(at point: CGPoint, xValue: Double, yValue: Double, on surface: SCIChartSurface) {
        let label = UILabel()
        let xFormatted = String(format: "%.2f", xValue)
        let yFormatted = String(format: "%.2f", yValue)
        label.text = "  \(xLabel): \(xFormatted)  \(yLabel): \(yFormatted)  "
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 0.05, green: 0.25, blue: 0.25, alpha: 0.92)
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        label.sizeToFit()

        let labelWidth = label.frame.width
        let labelHeight = label.frame.height

        var originX = point.x - labelWidth / 2
        var originY = point.y - labelHeight - 16

        originX = max(8, min(originX, surface.bounds.width - labelWidth - 8))
        if originY < 8 { originY = point.y + 16 }

        if let window = surface.window {
            let frameInWindow = surface.convert(
                CGRect(x: originX, y: originY, width: labelWidth, height: labelHeight),
                to: window
            )
            label.frame = frameInWindow
            window.addSubview(label)
            tooltipLabel = label
        }
    }

    func removeTooltip() {
        tooltipLabel?.removeFromSuperview()
        tooltipLabel = nil
    }

    // MARK: - Attach

    func attach(to surface: SCIChartSurface, zoomDirection: SCIDirection2D = .xyDirection, pinchDirection: SCIDirection2D = .xyDirection) {
        self.surface = surface

        let zoomPan = SCIZoomPanModifier()
        zoomPan.direction = zoomDirection

        let pinchZoom = SCIPinchZoomModifier()
        pinchZoom.direction = pinchDirection

        surface.chartModifiers.add(items:
            pinchZoom,
            zoomPan,
            SCIZoomExtentsModifier()
        )

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.numberOfTapsRequired = 1
        surface.addGestureRecognizer(tap)
    }
    
    // MARK: - Lifecycle

    func cleanup() {
        removeTooltip()
    }

    deinit {
        removeTooltip()
    }
}
