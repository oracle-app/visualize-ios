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
/// - `parseSuggestion(from:)`, converts a microservice response into a `ChartSuggestion`
///   for display in `VizReadyView`.

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
    /// Parses a JSON string into a `ChartSuggestion`, combining index metadata with chart data.
    /// Unsupported chart types return `nil`, they are not surfaced as suggestions.
    /// - Parameter jsonString: Raw JSON from the ML microservice (must include `chartIndex`).
    /// - Returns: A fully populated `ChartSuggestion`, or `nil` if malformed or unsupported.
    static func parseSuggestion(from jsonString: String) -> ChartSuggestion? {
        guard
            let data = jsonString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let chartIndex = json["chartIndex"] as? Int,
            let chartTypeString = json["chartType"] as? String,
            let chartType = ChartType.from(chartTypeString),
            let chart = parse(from: jsonString)
        else {
            print("ChartConfigParser.parseSuggestion: invalid JSON, missing chartIndex, or unsupported type")
            return nil
        }
        let chartName: String = (json["chartName"] as? String) ?? "Chart \(chartIndex)"
        return ChartSuggestion(id: chartIndex, name: chartName, chartType: chartType, chart: chart)
    }
}
