//
//  ChartTooltipCoordinator.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 12/05/26.
//

import UIKit
import SciChart
import os.log

class ChartTooltipCoordinator: NSObject {

    // MARK: - Supporting Types
    
    struct AreaSeriesEntry {
        let xValues: [Double]
        let yValues: [Double]
        let label: String
    }
    
    // MARK: - Properties

    weak var surface: SCIChartSurface?
    private weak var tooltipLabel: UILabel?
    private weak var tooltipArrow: UIView?
    let xLabel: String
    let yLabel: String
    var xValues: [Double] = []
    var yValues: [Double] = []
    var stackKeys: [String] = []
    var stackedSubSeries: [SCIStackedColumnRenderableSeries] = []
    var areaSeriesData: [AreaSeriesEntry] = []
    var isHorizontalChart: Bool = false
    
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

        if !areaSeriesData.isEmpty {
            handleAreaTap(at: location, seriesArea: seriesArea, surface: surface)
            return
        }

        if handleStackedTap(at: location, seriesArea: seriesArea, surface: surface) { return }
        if handleBarTap(at: location, seriesArea: seriesArea, surface: surface) { return }

        removeTooltip()
    }

    private func handleStackedTap(at location: CGPoint, seriesArea: UIView, surface: SCIChartSurface) -> Bool {
        for (stackIndex, stackedSeries) in stackedSubSeries.enumerated() {
            let hitTestInfo = SCIHitTestInfo()
            stackedSeries.hitTest(hitTestInfo, at: location)
            guard hitTestInfo.isHit else { continue }
            guard
                let xAxis = surface.xAxes.item(at: 0) as? SCINumericAxis,
                let yAxis = surface.yAxes.item(at: 0) as? SCINumericAxis,
                let ds = stackedSeries.dataSeries as? SCIXyDataSeries
            else { return false }

            let pointIndex = Int(hitTestInfo.pointSeriesIndex)
            guard pointIndex >= 0 && pointIndex < Int(ds.count) else { return false }

            let xValue = xValues.indices.contains(pointIndex)
                ? xValues[pointIndex]
                : Double(xAxis.currentCoordinateCalculator.getDataValue(Float(hitTestInfo.hitTestPoint.x)))

            let yValue: Double
            if let raw = ds.yValues.value(at: pointIndex) as? NSNumber {
                yValue = raw.doubleValue
            } else {
                yValue = Double(yAxis.currentCoordinateCalculator.getDataValue(Float(hitTestInfo.hitTestPoint.y)))
            }

            // Sum all segments up to stackIndex so the arrow points to the actual top of the tapped segment
            var cumulativeY = 0.0
            for subIdx in 0...stackIndex {
                if let subDs = stackedSubSeries[subIdx].dataSeries as? SCIXyDataSeries,
                   pointIndex < Int(subDs.count),
                   let raw = subDs.yValues.value(at: pointIndex) as? NSNumber {
                    cumulativeY += raw.doubleValue
                }
            }

            let stackLabel = stackKeys.indices.contains(stackIndex) ? stackKeys[stackIndex] : yLabel
            let pixelX = CGFloat(xAxis.currentCoordinateCalculator.getCoordinate(xValue))
            let pixelY = CGFloat(yAxis.currentCoordinateCalculator.getCoordinate(cumulativeY))
            let pointInSurface = seriesArea.convert(CGPoint(x: pixelX, y: pixelY), to: surface)
            removeTooltip()
            showTooltip(at: pointInSurface, xValue: xValue, yValue: yValue, overrideYLabel: stackLabel)
            return true
        }
        return false
    }

    private func handleBarTap(at location: CGPoint, seriesArea: UIView, surface: SCIChartSurface) -> Bool {
        for index in 0..<surface.renderableSeries.count {
            let series = surface.renderableSeries.item(at: index)
            let hitTestInfo = SCIHitTestInfo()
            series.hitTest(hitTestInfo, at: location)
            guard hitTestInfo.isHit else { continue }
            guard
                let xAxis = surface.xAxes.item(at: 0) as? SCINumericAxis,
                let yAxis = surface.yAxes.item(at: 0) as? SCINumericAxis
            else { return false }

            let pointIndex = Int(hitTestInfo.pointSeriesIndex)
            guard pointIndex >= 0 && pointIndex < xValues.count else { return false }

            let xValue = xValues[pointIndex]
            let yValue = yValues[pointIndex]

            let pointInSurface: CGPoint
            if isHorizontalChart {
                // Horizontal bars have swapped axes; center the tooltip at the bar midpoint
                let pixelX = CGFloat(yAxis.currentCoordinateCalculator.getCoordinate(yValue / 2))
                let pixelY = CGFloat(xAxis.currentCoordinateCalculator.getCoordinate(xValue))
                pointInSurface = seriesArea.convert(CGPoint(x: pixelX, y: pixelY), to: surface)
            } else {
                let pixelX = CGFloat(xAxis.currentCoordinateCalculator.getCoordinate(xValue))
                let pixelY = CGFloat(yAxis.currentCoordinateCalculator.getCoordinate(yValue))
                pointInSurface = seriesArea.convert(CGPoint(x: pixelX, y: pixelY), to: surface)
            }

            removeTooltip()
            showTooltip(at: pointInSurface, xValue: xValue, yValue: yValue)
            return true
        }
        return false
    }
    
    private func handleAreaTap(at location: CGPoint, seriesArea: UIView, surface: SCIChartSurface) {
        guard
            let xAxis = surface.xAxes.item(at: 0) as? SCINumericAxis,
            let yAxis = surface.yAxes.item(at: 0) as? SCINumericAxis
        else { return }

        let tappedX = Double(xAxis.currentCoordinateCalculator.getDataValue(Float(location.x)))
        let tappedY = Double(yAxis.currentCoordinateCalculator.getDataValue(Float(location.y)))

        var bestPointIndex = 0
        var bestSeriesIndex = 0
        var bestDistance = Double.infinity

        // Find the data point closest to the tap in Y across all series
        for (sIdx, data) in areaSeriesData.enumerated() {
            guard let pIdx = data.xValues.indices.min(by: {
                abs(data.xValues[$0] - tappedX) < abs(data.xValues[$1] - tappedX)
            }) else { continue }

            let dy = abs(data.yValues[pIdx] - tappedY)
            if dy < bestDistance {
                bestDistance = dy
                bestPointIndex = pIdx
                bestSeriesIndex = sIdx
            }
        }

        // Convert 40 screen points into data units for a zoom-invariant threshold
        let threshold = abs(
            Double(yAxis.currentCoordinateCalculator.getDataValue(Float(location.y + 40)))
            - Double(yAxis.currentCoordinateCalculator.getDataValue(Float(location.y)))
        )

        guard bestDistance < threshold else {
            removeTooltip()
            return
        }

        let data = areaSeriesData[bestSeriesIndex]
        let xValue = data.xValues[bestPointIndex]
        let yValue = data.yValues[bestPointIndex]

        let pixelX = CGFloat(xAxis.currentCoordinateCalculator.getCoordinate(xValue))
        let pixelY = CGFloat(yAxis.currentCoordinateCalculator.getCoordinate(yValue))
        let pointInSurface = seriesArea.convert(CGPoint(x: pixelX, y: pixelY), to: surface)

        removeTooltip()
        showTooltip(at: pointInSurface, xValue: xValue, yValue: yValue, overrideYLabel: data.label)
    }
    // Dismiss the tooltip as soon as the user starts panning the chart
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            removeTooltip()
        }
    }

    // MARK: - Tooltip

    /// Builds and displays the tooltip bubble + arrow at the given surface-space point.
    /// Exposed as internal so chart views using tapOverride can call it directly.
    func showTooltip(at point: CGPoint, xValue: Double, yValue: Double, overrideYLabel: String? = nil) {
        removeTooltip()
        guard let surface else { return }

        let displayYLabel = overrideYLabel ?? yLabel
        let tooltipColor = UIColor(red: 0.05, green: 0.25, blue: 0.25, alpha: 0.92)

        // MARK: Label
        let label = UILabel()
        label.text = "  \(xLabel): \(String(format: "%.2f", xValue))  \(displayYLabel): \(String(format: "%.2f", yValue))  "
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.backgroundColor = tooltipColor
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        label.sizeToFit()

        let labelWidth = label.frame.width
        let labelHeight = label.frame.height

        // MARK: Arrow
        let arrowSize = CGSize(width: 12, height: 7)
        let arrowView = UIView(frame: CGRect(x: 0, y: 0, width: arrowSize.width, height: arrowSize.height))
        arrowView.backgroundColor = .clear

        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 0, y: 0))
        arrowPath.addLine(to: CGPoint(x: arrowSize.width, y: 0))
        arrowPath.addLine(to: CGPoint(x: arrowSize.width / 2, y: arrowSize.height))
        arrowPath.close()

        let arrowLayer = CAShapeLayer()
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.fillColor = tooltipColor.cgColor
        arrowView.layer.addSublayer(arrowLayer)

        // MARK: Layout
        // Attach to the topmost subview so the tooltip renders above the chart canvas
        let container = surface.subviews.last ?? surface
        let containerPoint = surface.convert(point, to: container)

        var labelOriginX = containerPoint.x - labelWidth / 2
        var labelOriginY = containerPoint.y - labelHeight - arrowSize.height - 8

        // Clamp horizontally so the label never clips outside the container
        labelOriginX = max(8, min(labelOriginX, container.bounds.width - labelWidth - 8))

        // Flip below the point if there isn't enough room above
        let goesBelow = labelOriginY < 8
        if goesBelow {
            labelOriginY = containerPoint.y + arrowSize.height + 8
        }

        let arrowOriginX = containerPoint.x - arrowSize.width / 2
        let arrowOriginY = goesBelow
            ? containerPoint.y + 8
            : containerPoint.y - arrowSize.height - 8

        if goesBelow {
            arrowView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }

        label.frame = CGRect(x: labelOriginX, y: labelOriginY, width: labelWidth, height: labelHeight)
        arrowView.frame = CGRect(x: arrowOriginX, y: arrowOriginY, width: arrowSize.width, height: arrowSize.height)

        container.addSubview(label)
        container.addSubview(arrowView)

        tooltipLabel = label
        tooltipArrow = arrowView
    }

    // MARK: - Remove

    func removeTooltip() {
        tooltipLabel?.removeFromSuperview()
        tooltipLabel = nil
        tooltipArrow?.removeFromSuperview()
        tooltipArrow = nil
    }

    // MARK: - Attach

    func attach(
        to surface: SCIChartSurface,
        zoomDirection: SCIDirection2D = .xyDirection,
        pinchDirection: SCIDirection2D = .xyDirection,
        onAttach: ((ChartTooltipCoordinator) -> Void)? = nil
    ) {
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

        // Pan gesture is only used to dismiss the tooltip on drag start;
        // it runs simultaneously with SciChart's own pan modifier
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        surface.addGestureRecognizer(pan)

        onAttach?(self)
    }

    // MARK: - Viewport Snapshot

    /// Reads the current X/Y visible ranges from the live surface.
    /// Returns nil only when surface is nil; a single-axis cast failure
    /// defaults that axis to nil while the other is still returned.
    @MainActor
    func currentViewport() -> ChartViewport? {
        guard let surface else {
            os_log(.error, log: SnipCaptureLog.general,
                   "currentViewport: surface ref is nil — falling back to default range")
            return nil
        }

        let x: ClosedRange<Double>?
        if let r = surface.xAxes.item(at: 0).visibleRange as? SCIDoubleRange {
            x = r.min.toDouble()...r.max.toDouble()
        } else {
            os_log(.error, log: SnipCaptureLog.general,
                   "currentViewport: xAxis visibleRange is not SCIDoubleRange — using nil")
            x = nil
        }

        let y: ClosedRange<Double>?
        if let r = surface.yAxes.item(at: 0).visibleRange as? SCIDoubleRange {
            y = r.min.toDouble()...r.max.toDouble()
        } else {
            os_log(.error, log: SnipCaptureLog.general,
                   "currentViewport: yAxis visibleRange is not SCIDoubleRange — using nil")
            y = nil
        }

        return ChartViewport(xRange: x, yRange: y)
    }

    // MARK: - Lifecycle

    func cleanup() {
        removeTooltip()
    }

    deinit {
        removeTooltip()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ChartTooltipCoordinator: UIGestureRecognizerDelegate {
    // Allow the pan gesture to run simultaneously with SciChart's own pan modifier
    // so drag-start detection doesn't block chart interaction
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
