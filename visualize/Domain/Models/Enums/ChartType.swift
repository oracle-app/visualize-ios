//
//  ChartType.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 05/05/26.
//

enum ChartType: String {
    case verticalBar = "Vertical Bar Chart"
    case horizontalBar = "Horizontal Bar Chart"
    case stackedBar = "Stacked Bar Chart"
    case line = "Line"
    case pie = "Pie"
    case donut = "Donut"
    case scatter = "Scatter"
    case area = "Area"
    case tile = "Tile"

    nonisolated static func from(_ typeName: String) -> ChartType? {
        ChartType(rawValue: typeName)
    }
}
