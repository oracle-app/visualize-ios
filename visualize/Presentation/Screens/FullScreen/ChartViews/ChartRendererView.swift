//
//  ChartRendererView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 05/05/26.
//
//
/// Central router that receives a ChartData model and renders
/// the corresponding SciChart view based on the chart type.
/// Add new chart type cases here as they are implemented.

import SwiftUI
struct ChartRendererView: View {
    
    // MARK: - Properties
    /// The parsed chart model containing type and data.
    let chart: ChartData
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
            
            // MARK: Vertical Bar
            case .verticalBar(_, let data, let fieldNames):
                VerticalBarChartView(
                    categories: sortedKeys(from: data),
                    values: sortedValues(from: data),
                    xLabel: fieldNames.first ?? "X",
                    yLabel: fieldNames.last ?? "Y"
                )
            
            // MARK: Horizontal Bar
            case .horizontalBar:
                ContentUnavailableView(
                    "Coming Soon",
                    systemImage: "chart.bar.fill",
                    description: Text("Horizontal bar chart will be available soon.")
                )
            
            // MARK: Stacked Bar
            case .stackedBar(_, let data, let stackNames):
                StackedBarChartView(
                    data: data,
                    categories: stackNames,
                    xLabel: "Category",
                    yLabel: "Count"
                )
            
            // MARK: Line
            case .line(_, let data, let fieldNames):
                LineChartView(
                    data: data,
                    xLabel: fieldNames.first ?? "X",
                    yLabel: fieldNames.last ?? "Y"
                )
            
            // MARK: Pie
            case .pie(_, let data, let fieldNames):
                PieChartView(
                    values: data,
                    labels: fieldNames
                )
            
            // MARK: Donut
            case .donut(_, let data, let fieldNames):
                DonutChartView(
                    values: data,
                    labels: fieldNames
                )
            
            // MARK: Area
            case .area:
                ContentUnavailableView(
                    "Coming Soon",
                    systemImage: "chart.xyaxis.line",
                    description: Text("This chart type will be available soon.")
                )
     
            // MARK: Tile
            case .tile:
                ContentUnavailableView(
                    "Coming Soon",
                    systemImage: "chart.xyaxis.line",
                    description: Text("This chart type will be available soon.")
                )
            
            // MARK: Unsupported
            case .unsupported(let type):
                ContentUnavailableView(
                    "Type not supported: \(type)",
                    systemImage: "chart.xyaxis.line"
            )
        }
    }
    
    // MARK: - Private Helpers
    /// Returns keys sorted numerically when possible, alphabetically otherwise.
    /// - Parameter data: The bar chart data dictionary.
    /// - Returns: Sorted keys array.
    private func sortedKeys(from data: [String: Double]) -> [String] {
        data.keys.sorted { lhs, rhs in
            if let lNum = Double(lhs), let rNum = Double(rhs) { return lNum < rNum }
            return lhs < rhs
        }
    }
 
    /// Returns values in the same order as `sortedKeys(from:)`.
    /// - Parameter data: The bar chart data dictionary.
    /// - Returns: Values array matching sorted key order.
    private func sortedValues(from data: [String: Double]) -> [Double] {
        sortedKeys(from: data).compactMap { data[$0] }
    }
}
