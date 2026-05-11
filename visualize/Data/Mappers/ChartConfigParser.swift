//
//  ChartConfigParser.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 05/05/26.
//
/// Parses raw JSON strings into typed chart domain models.
/// Used in two contexts:
/// - `parse(from:)`, converts a `configJSON` string into a `ChartData`
///   for rendering in `FullScreenView`.
/// - `parseSuggestion(configJSON:previewJSON:)`, builds a `ChartSuggestion` for VizReady.
///   The `ChartData` used for card previews is parsed from `previewJSON` (reduced data).
///   Both raw strings are preserved so they can be saved separately to Firestore on confirmation.

import Foundation

struct ChartConfigParser {
    // MARK: - Parse
    
    /// Parses a JSON string into a `ChartData` model.
    /// Returns `nil` if the JSON is malformed or missing required fields.
    /// Returns `.unsupported` if the chart type is not recognized.
    static func parse(from jsonString: String) -> ChartData? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let chartTypeString = json["chartType"] as? String,
              let chartName = json["chartName"] as? String,
              let metrics = json["metrics"] as? [String: String],
              let dataDict = json["data"] as? [String: Any] else {
            print("ChartConfigParser: invalid JSON or missing required fields")
            return nil
        }
        guard let chartType = ChartType.from(chartTypeString) else {
            return .unsupported(type: chartTypeString)
        }
        
        // MARK: Field Extraction
        
        let field1Label = metrics["field1"] ?? "X"
        let field2Label = metrics["field2"] ?? "Y"
        let field1Raw = dataDict["field1"] as? [String] ?? []
        let field2Raw = dataDict["field2"] as? [String] ?? []
        let field1Values = field1Raw.compactMap { Double($0) }
        let field2Values = field2Raw.compactMap { Double($0) }

        // MARK: Chart Type Routing
        
        switch chartType {
        case .scatter:
            let points = zip(field1Values, field2Values).map { (x: $0, y: $1) }
            return .scatter(title: chartName, data: points, fieldNames: [field1Label, field2Label])
        case .line:
            var lineData: [Double: Double] = [:]
            zip(field1Values, field2Values).forEach { lineData[$0] = $1 }
            return .line(title: chartName, data: lineData, fieldNames: [field1Label, field2Label])
        case .verticalBar:
            var barData: [String: Double] = [:]
            zip(field1Raw, field2Values).forEach { barData[$0] = $1 }
            return .verticalBar(title: chartName, data: barData, fieldNames: [field1Label, field2Label])
        case .horizontalBar:
            var barData: [String: Double] = [:]
            zip(field1Raw, field2Values).forEach { barData[$0] = $1 }
            return .horizontalBar(title: chartName, data: barData, fieldNames: [field1Label, field2Label])
        case .stackedBar:
            var stackedData: [String: [Double]] = [:]
            if let field2Dict = dataDict["field2"] as? [String: Any] {
                for (key, rawValue) in field2Dict {
                    if let strArr = rawValue as? [String] {
                        stackedData[key] = strArr.compactMap { Double($0) }
                    } else if let numArr = rawValue as? [NSNumber] {
                        stackedData[key] = numArr.map { $0.doubleValue }
                    }
                }
            }
            return .stackedBar(title: chartName, data: stackedData, stackNames: field1Raw)
        case .pie:
            return .pie(title: chartName, data: field2Values, fieldNames: field1Raw)
        case .donut:
            return .donut(title: chartName, data: field2Values, fieldNames: field1Raw)
        case .area:
            var areaData: [String: [Double]] = [:]
            zip(field1Raw, field2Values).forEach { areaData[$0] = [$1] }
            return .area(title: chartName, data: areaData, stackNames: [field1Label, field2Label])
        case .tile:
            let value = field1Values.first ?? 0
            return .tile(title: chartName, value: value, label: field1Label)
        }
    }
    
    // MARK: - Parse Suggestion
    /// Builds a `ChartSuggestion` from a config/preview JSON pair.
    /// - The `ChartData` used for card rendering in VizReady is parsed from `previewJSON`
    ///   (reduced data, fewer points).
    /// - Chart metadata (index, name, type) is extracted from `configJSON`.
    /// - Both raw strings are stored in the suggestion so they can be saved separately
    ///   to Firestore when the user confirms: `configJSON` for `FullScreenView`,
    ///   `previewJSON` for feed card previews.
    /// - Unsupported chart types return `nil`.
    ///
    /// - Parameters:
    ///   - configJSON: Full JSON from the microservice with all data points.
    ///   - previewJSON: Reduced JSON with fewer data points for fast card rendering.
    /// - Returns: A fully populated `ChartSuggestion`, or `nil` if malformed or unsupported.
    ///
    static func parseSuggestion(configJSON: String, previewJSON: String) -> ChartSuggestion? {
        guard
            let data = configJSON.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let chartIndex = json["chartIndex"] as? Int,
            let chartTypeString = json["chartType"] as? String,
            let chartType = ChartType.from(chartTypeString),
            // Parse ChartData from previewJSON, this is what gets rendered on the card
            let chart = parse(from: previewJSON)
        else {
            print("ChartConfigParser.parseSuggestion: invalid JSON, missing chartIndex, or unsupported type")
            return nil
        }
        let chartName: String = (json["chartName"] as? String) ?? "Chart \(chartIndex)"
        return ChartSuggestion(id: chartIndex, name: chartName, chartType: chartType, chart: chart, previewJSON: previewJSON, configJSON: configJSON)
    }
}
