//
//  ChartViewport.swift
//  visualize
//
//  Created by SDD Apply on 13/05/26.
//
/// Captured X/Y visible ranges read from a live SCIChartSurface at snap time.
/// Both fields are optional: a nil field means "use default axis range".
struct ChartViewport: Equatable, Sendable {
    let xRange: ClosedRange<Double>?
    let yRange: ClosedRange<Double>?

    static let `default` = ChartViewport(xRange: nil, yRange: nil)
}
