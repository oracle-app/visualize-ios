//
//  ChartFullScreen.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 05/05/26.
//

enum ChartFullScreen {
    case verticalBar(title: String, data: [String: Double], fieldNames: [String])
    case horizontalBar(title: String, data: [String: Double], fieldNames: [String])
    case stackedBar(title: String, data: [String: [Double]], stackNames: [String])
    case line(title: String, data: [Double: Double], fieldNames: [String])
    case pie(title: String, data: [Double], fieldNames: [String])
    case donut(title: String, data: [Double], fieldNames: [String])
    case scatter(title: String, data: [(x: Double, y: Double)], fieldNames: [String])
    case area(title: String, data: [String: [Double]], stackNames: [String])
    case tile(title: String, value: Double, label: String)
    case unsupported(type: String)
}
