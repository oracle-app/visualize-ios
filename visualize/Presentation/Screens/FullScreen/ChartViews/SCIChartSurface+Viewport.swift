//
//  SCIChartSurface+Viewport.swift
//  visualize
//
//  Created by SDD Apply on 13/05/26.
//

import SciChart
import os.log

extension SCIChartSurface {
    /// Applies an optional viewport override to axis 0.
    /// No-op when viewport is nil or both ranges are nil.
    /// Preserves os_log format from PR #62 verbatim.
    func applyViewport(_ viewport: ChartViewport?) {
        guard let vp = viewport else { return }
        if let xr = vp.xRange {
            xAxes.item(at: 0).visibleRange = SCIDoubleRange(min: xr.lowerBound, max: xr.upperBound)
        }
        if let yr = vp.yRange {
            yAxes.item(at: 0).visibleRange = SCIDoubleRange(min: yr.lowerBound, max: yr.upperBound)
        }
        os_log(.debug, log: SnipCaptureLog.general,
               "Viewport applied: x=%{public}@  y=%{public}@",
               String(describing: vp.xRange), String(describing: vp.yRange))
    }
}
