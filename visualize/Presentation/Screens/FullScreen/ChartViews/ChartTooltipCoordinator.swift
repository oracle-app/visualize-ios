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

    // MARK: - Properties

    weak var surface: SCIChartSurface?
    private weak var tooltipLabel: UILabel?
    private weak var tooltipArrow: UIView?
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

                if isStackedChart {
                    guard
                        let xAxis = surface.xAxes.item(at: 0) as? SCINumericAxis,
                        let yAxis = surface.yAxes.item(at: 0) as? SCINumericAxis
                    else { return }

                    let pointIndex = Int(hitTestInfo.pointSeriesIndex)
                    let xValue = pointIndex >= 0 && pointIndex < xValues.count
                        ? xValues[pointIndex]
                        : Double(xAxis.currentCoordinateCalculator.getDataValue(Float(hitTestInfo.hitTestPoint.x)))
                    let yValue = Double(yAxis.currentCoordinateCalculator.getDataValue(Float(hitTestInfo.hitTestPoint.y)))

                    showTooltip(at: gesture.location(in: surface), xValue: xValue, yValue: yValue)
                } else {
                    let pointIndex = Int(hitTestInfo.pointSeriesIndex)
                    guard pointIndex >= 0 && pointIndex < xValues.count else { return }

                    showTooltip(
                        at: gesture.location(in: surface),
                        xValue: xValues[pointIndex],
                        yValue: yValues[pointIndex]
                    )
                }
                return
            }
        }

        removeTooltip()
    }

    // Dismiss tooltip as soon as the user starts panning the chart
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            removeTooltip()
        }
    }

    // MARK: - Tooltip

    private func showTooltip(at point: CGPoint, xValue: Double, yValue: Double) {
        removeTooltip()
        guard let surface else { return }

        let tooltipColor = UIColor(red: 0.05, green: 0.25, blue: 0.25, alpha: 0.92)

        // MARK: Label

        let label = UILabel()
        label.text = "  \(xLabel): \(String(format: "%.2f", xValue))  \(yLabel): \(String(format: "%.2f", yValue))  "
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

        let container = surface.subviews.last ?? surface

        // Convert the tap point from surface space to container space
        let containerPoint = surface.convert(point, to: container)

        var labelOriginX = containerPoint.x - labelWidth / 2
        var labelOriginY = containerPoint.y - labelHeight - arrowSize.height - 8

        // Clamp horizontally within container bounds
        labelOriginX = max(8, min(labelOriginX, container.bounds.width - labelWidth - 8))

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

        // Add to the topmost subview of the surface so the tooltip renders above
        // the chart canvas but stays within the screenshot preventer mask
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

        // Pan gesture used only to dismiss the tooltip when the user starts dragging
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        surface.addGestureRecognizer(pan)

        onAttach?(self)
    }

    // MARK: - Viewport Snapshot

    /// Reads the current X/Y visible ranges from the live surface.
    /// Returns `nil` only when `surface` is nil; a single-axis cast failure
    /// defaults that axis to nil while the other axis is still honored.
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
    // so we can detect drag start without blocking chart interaction
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
