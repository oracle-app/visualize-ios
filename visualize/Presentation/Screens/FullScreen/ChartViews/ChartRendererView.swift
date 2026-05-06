//
//  ChartRendererView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 05/05/26.
//
//
/// Central router that receives a ChartFullScreen model and renders
/// the corresponding SciChart view based on the chart type.
/// Add new chart type cases here as they are implemented.

import SwiftUI

struct ChartRendererView: View {

    // MARK: - Properties

    /// The parsed chart model containing type and data.
    let chart: ChartFullScreen

    // MARK: - Body

    var body: some View {
        switch chart {

        // MARK: Scatter
        case .scatter(_, let data, let fieldNames):
            ScatterChartView(
                xValues: data.map { $0.x },
                yValues: data.map { $0.y },
                xLabel: fieldNames.first ?? "X",
                yLabel: fieldNames.last ?? "Y"
            )

        // MARK: Unsupported
        case .unsupported(let type):
            ContentUnavailableView(
                "Type not supported: \(type)",
                systemImage: "chart.xyaxis.line"
            )

        // MARK: Coming Soon
        default:
            ContentUnavailableView(
                "Coming Soon",
                systemImage: "chart.xyaxis.line",
                description: Text("This chart type will be available soon.")
            )
        }
    }
}
