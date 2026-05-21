//
//  ChartData.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 08/05/26.
//

struct ScatterPoint: Hashable, Equatable {
    let x: Double
    let y: Double
}

/// Typed chart model used for both card previews in VizReady and full-screen rendering.
/// Parsed from a JSON string by `ChartConfigParserxs`.
enum ChartData: Hashable, Equatable {
    case verticalBar(title: String, data: [String: Double], fieldNames: [String])
    case horizontalBar(title: String, data: [String: Double], fieldNames: [String])
    case stackedBar(title: String, data: [String: [Double]], stackNames: [String])
    case line(title: String, data: [Double: Double], fieldNames: [String])
    case pie(title: String, data: [Double], fieldNames: [String])
    case donut(title: String, data: [Double], fieldNames: [String])
    case scatter(title: String, data: [ScatterPoint], fieldNames: [String])
    case area(title: String, data: [String: [Double]], stackNames: [String])
    case tile(title: String, value: Double, label: String)
    case unsupported(type: String)
}
