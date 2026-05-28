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

import Foundation
 
// MARK: - DTO
 
/// Mirrors the JSON shape returned by the microservice for a single chart.
private struct ChartConfigDTO: Decodable {
    let chartIndex: Int?
    let chartName: String?
    let chartType: String
    let data: ChartDataDTO?
    let metrics: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case chartIndex, chartName, chartType, data, metrics
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // chartIndex can be Int or String depending on how old the Firestore document is.
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: .chartIndex) {
            chartIndex = intValue
        } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .chartIndex) {
            chartIndex = Int(stringValue)
        } else {
            chartIndex = nil
        }
        chartName = try container.decodeIfPresent(String.self, forKey: .chartName)
        chartType = try container.decode(String.self, forKey: .chartType)
        data      = try container.decodeIfPresent(ChartDataDTO.self, forKey: .data)
        metrics   = try container.decodeIfPresent([String: String].self, forKey: .metrics)
    }
}
 
/// Mirrors the `data` sub-object, which contains `field1` and `field2`.
private struct ChartDataDTO: Decodable {
    let field1: AnyField?
    let field2: AnyField?
}
 
// MARK: - AnyField
 
/// Polymorphic decoder for the `field1` and `field2` values in the chart `data` block.
///
/// The microservice returns these in several shapes depending on chart type:
/// - `[String]` , category labels used by vertical bar, horizontal bar, pie, donut.
/// - `[Double]` , numeric axis values used by scatter and line.
/// - `[String: [Double]]` , stacked series keyed by series name, used by stacked bar and area.
///   String-array variant (`[String: [String]]`) is also accepted and converted to doubles.
///
/// The enum tries each shape in order and throws only if none match.
private enum AnyField: Decodable {
    case strings([String])
    case numbers([Double])
    case stackedSeries([String: [Double]])
 
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
 
        if let numbers = try? container.decode([Double].self) {
            self = .numbers(numbers)
            return
        }
        if let strings = try? container.decode([String].self) {
            self = .strings(strings)
            return
        }
        if let dict = try? container.decode([String: [Double]].self) {
            self = .stackedSeries(dict)
            return
        }
        if let dict = try? container.decode([String: [String]].self) {
            self = .stackedSeries(dict.mapValues { $0.compactMap { Double($0) } })
            return
        }
        throw DecodingError.typeMismatch(
            AnyField.self,
            DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "AnyField: could not decode as strings, numbers, or stacked dict."
            )
        )
    }
 
    // MARK: Convenience Accessors
 
    /// Returns the value as `[String]`. Numbers are converted to their string representation.
    var asStrings: [String] {
        switch self {
        case .strings(let s):
            return s
        case .numbers(let n):
            return n.map { String($0) }
        case .stackedSeries:
            return []
        }
    }
 
    /// Returns the value as `[Double]`. String values are parsed via `Double(_:)`.
    var asDoubles: [Double] {
        switch self {
        case .strings(let s):
            return s.compactMap { Double($0) }
        case .numbers(let n):
            return n
        case .stackedSeries:
            return []
        }
    }
 
    /// Returns the value as `[String: [Double]]`. Empty dict for non-stacked types.
    var asStackedSeries: [String: [Double]] {
        if case .stackedSeries(let d) = self {
            return d
        }
        return [:]
    }
}
 
// MARK: - Parser
 
struct ChartConfigParser {
 
    // MARK: - Parse
 
    /// Parses a JSON string into a `ChartData` model.
    /// Returns `nil` if the JSON is malformed or missing required fields.
    /// Returns `.unsupported` if the chart type is not recognized.
    static func parse(from jsonString: String) -> ChartData? {
        guard let data = jsonString.data(using: .utf8) else {
            print("ChartConfigParser: could not encode JSON string as UTF-8")
            return nil
        }
        do {
            let dto = try JSONDecoder().decode(ChartConfigDTO.self, from: data)
            return chartData(from: dto)
        } catch {
            print("ChartConfigParser: decode error — \(error)")
            return nil
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
    static func parseSuggestion(configJSON: String, previewJSON: String) -> ChartSuggestion? {
        guard let configData = configJSON.data(using: .utf8) else { return nil }
 
        do {
            let dto = try JSONDecoder().decode(ChartConfigDTO.self, from: configData)
            guard
                let chartIndex = dto.chartIndex,
                let chartType = ChartType.from(dto.chartType),
                // Parse ChartData from previewJSON, this is what gets rendered on the card
                let chart = parse(from: previewJSON)
            else {
                print("ChartConfigParser.parseSuggestion: missing chartIndex or unsupported type")
                return nil
            }
            let chartName = dto.chartName ?? "Chart \(chartIndex)"
            return ChartSuggestion(
                id: chartIndex,
                name: chartName,
                chartType: chartType,
                chart: chart,
                previewJSON: previewJSON,
                configJSON: configJSON
            )
        } catch {
            print("ChartConfigParser.parseSuggestion: decode error — \(error)")
            return nil
        }
    }
 
    // MARK: - DTO to ChartData
 
    /// Maps a decoded `ChartConfigDTO` to the appropriate `ChartData` case.
    /// Returns `.unsupported` for unknown type strings.
    private static func chartData(from dto: ChartConfigDTO) -> ChartData? {
        guard let chartType = ChartType.from(dto.chartType) else {
            return .unsupported(type: dto.chartType)
        }
 
        let chartName = dto.chartName ?? "Chart"
        let metrics = dto.metrics ?? [:]
        let field1Label = metrics["field1"] ?? "X"
        let field2Label = metrics["field2"] ?? "Y"
 
        // Field Extraction
 
        let field1Strings = dto.data?.field1?.asStrings ?? []
        let field1Doubles = dto.data?.field1?.asDoubles ?? []
        let field2Doubles = dto.data?.field2?.asDoubles ?? []
 
        // Chart Type Routing
 
        switch chartType {
        case .scatter:
            let points = zip(field1Doubles, field2Doubles).map { ScatterPoint(x: $0, y: $1) }
            return .scatter(title: chartName, data: points, fieldNames: [field1Label, field2Label])
 
        case .line:
            var lineData: [Double: Double] = [:]
            zip(field1Doubles, field2Doubles).forEach { lineData[$0] = $1 }
            return .line(title: chartName, data: lineData, fieldNames: [field1Label, field2Label])
 
        case .verticalBar:
            var barData: [String: Double] = [:]
            zip(field1Strings, field2Doubles).forEach { barData[$0] = $1 }
            return .verticalBar(title: chartName, data: barData, fieldNames: [field1Label, field2Label])
 
        case .horizontalBar:
            var barData: [String: Double] = [:]
            zip(field1Strings, field2Doubles).forEach { barData[$0] = $1 }
            return .horizontalBar(title: chartName, data: barData, fieldNames: [field1Label, field2Label])
 
        case .stackedBar:
            let stackedData = dto.data?.field2?.asStackedSeries ?? [:]
            return .stackedBar(title: chartName, data: stackedData, stackNames: field1Strings)
 
        case .pie:
            return .pie(title: chartName, data: field2Doubles, fieldNames: field1Strings)
 
        case .donut:
            return .donut(title: chartName, data: field2Doubles, fieldNames: field1Strings)
 
        case .area:
            let areaData = dto.data?.field2?.asStackedSeries ?? [:]
            return .area(title: chartName, data: areaData, stackNames: field1Strings)
 
        case .tile:
            let value = field1Doubles.first ?? 0
            return .tile(title: chartName, value: value, label: field1Label)
        }
    }
}
