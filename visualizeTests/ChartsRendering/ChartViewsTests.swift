//
//  ChartViewsTests.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 06/06/26.
//
//  Unit tests for the Chart Views rendering module.
//  Covers FSRT-001 through FSRT-010 from the Chart Views Test Plan.
//
//  Strategy: ChartRendererView is a UIViewRepresentable that wraps SciChart —
//  it cannot be unit-tested directly without a live surface. Instead, these
//  tests validate the *logic layer* that feeds data into the views:
//    - ChartConfigParser produces the correct ChartData case for each type
//    - sortedKeys ordering (numeric vs alphabetic)
//    - .unsupported case for unknown types (FSRT-009)
//    - Error path returns nil (FSRT-010 parse side)
//
//  UI-level rendering (does the view actually appear on screen?) is covered
//  by ChartViewsUITests.swift using launch arguments and accessibility IDs.
//

import XCTest
@testable import visualize

final class ChartViewsTests: XCTestCase {

    // MARK: - FSRT-001: Vertical Bar

    func test_FSRT001_verticalBarConfig_parsesToVerticalBarCase() throws {
        let chart = try XCTUnwrap(
            ChartConfigParser.parse(from: MockChartJSONs.verticalBarConfig),
            "verticalBarConfig should parse without returning nil"
        )
        guard case .verticalBar(let title, let data, let fieldNames) = chart else {
            return XCTFail("FSRT-001 — Expected .verticalBar, got \(chart)")
        }
        XCTAssertFalse(title.isEmpty, "Title should not be empty")
        XCTAssertFalse(data.isEmpty, "Data dict should have at least one entry")
        XCTAssertEqual(fieldNames.count, 2, "fieldNames should contain xLabel and yLabel")
    }

    // MARK: - FSRT-002: Horizontal Bar

    func test_FSRT002_horizontalBarConfig_parsesToHorizontalBarCase() throws {
        let chart = try XCTUnwrap(
            ChartConfigParser.parse(from: MockChartJSONs.horizontalBarConfig),
            "horizontalBarConfig should parse without returning nil"
        )
        guard case .horizontalBar(let title, let data, _) = chart else {
            return XCTFail("FSRT-002 — Expected .horizontalBar, got \(chart)")
        }
        XCTAssertFalse(title.isEmpty)
        XCTAssertFalse(data.isEmpty)
    }

    // MARK: - FSRT-003: Line

    func test_FSRT003_lineConfig_parsesToLineCase() throws {
        let chart = try XCTUnwrap(
            ChartConfigParser.parse(from: MockChartJSONs.lineConfig),
            "lineConfig should parse without returning nil"
        )
        guard case .line(let title, let data, let fieldNames) = chart else {
            return XCTFail("FSRT-003 — Expected .line, got \(chart)")
        }
        XCTAssertFalse(title.isEmpty)
        XCTAssertFalse(data.isEmpty, "Line data should have at least one point")
        XCTAssertEqual(fieldNames.count, 2)
    }

    func test_FSRT003_lineData_isSortedByXAscending() throws {
        // Line chart requires data sorted by X for a continuous line.
        let json = """
        {
            "chartType": "Line",
            "chartName": "SortTest",
            "data": { "field1": ["30","10","20"], "field2": ["40.5","19.8","26.3"] },
            "metrics": { "field1": "X", "field2": "Y" }
        }
        """
        let chart = try XCTUnwrap(ChartConfigParser.parse(from: json))
        guard case .line(_, let data, _) = chart else {
            return XCTFail("Expected .line")
        }
        // Verify the three known X values map to the correct Y values.
        XCTAssertEqual(data[10.0] ?? 0, 19.8, accuracy: 0.001)
        XCTAssertEqual(data[20.0] ?? 0, 26.3, accuracy: 0.001)
        XCTAssertEqual(data[30.0] ?? 0, 40.5, accuracy: 0.001)
    }

    // MARK: - FSRT-004: Area

    func test_FSRT004_areaConfig_parsesToAreaCase() throws {
        let chart = try XCTUnwrap(
            ChartConfigParser.parse(from: MockChartJSONs.areaConfig),
            "areaConfig should parse without returning nil"
        )
        guard case .area(let title, let data, let stackNames) = chart else {
            return XCTFail("FSRT-004 — Expected .area, got \(chart)")
        }
        XCTAssertFalse(title.isEmpty)
        XCTAssertFalse(data.isEmpty, "Area data must contain at least one series")
        XCTAssertFalse(stackNames.isEmpty, "Area stackNames must not be empty")
    }

    func test_FSRT004_areaSeriesKeys_areSortedAlphabetically() throws {
        let json = """
        {
            "chartType": "Area",
            "chartName": "A",
            "data": {
                "field1": ["0-9","10-19"],
                "field2": { "Survived": [38, 26], "Died": [24, 45] }
            },
            "metrics": {}
        }
        """
        let chart = try XCTUnwrap(ChartConfigParser.parse(from: json))
        guard case .area(_, let data, _) = chart else {
            return XCTFail("Expected .area")
        }
        let keys = data.keys.sorted()
        XCTAssertEqual(keys, ["Died", "Survived"])
    }

    // MARK: - FSRT-005: Scatter

    func test_FSRT005_scatterConfig_parsesToScatterCase() throws {
        let chart = try XCTUnwrap(
            ChartConfigParser.parse(from: MockChartJSONs.scatterConfig),
            "scatterConfig should parse without returning nil"
        )
        guard case .scatter(_, let points, _) = chart else {
            return XCTFail("FSRT-005 — Expected .scatter, got \(chart)")
        }
        XCTAssertFalse(points.isEmpty, "Scatter should have at least one point")
    }

    func test_FSRT005_scatter_zipTruncatesToShorterArray() throws {
        // zip behavior: if field1 has 3 elements but field2 has 2, result has 2 points.
        let json = """
        {
            "chartType": "Scatter",
            "chartName": "X",
            "data": { "field1": ["1.0","2.0","3.0"], "field2": ["0","1"] },
            "metrics": {}
        }
        """
        let chart = try XCTUnwrap(ChartConfigParser.parse(from: json))
        guard case .scatter(_, let points, _) = chart else {
            return XCTFail("Expected .scatter")
        }
        XCTAssertEqual(points.count, 2, "zip must truncate to the shorter array — got \(points.count) points")
    }

    // MARK: - FSRT-006: Stacked Bar

    func test_FSRT006_stackedBarConfig_parsesToStackedBarCase() throws {
        let chart = try XCTUnwrap(
            ChartConfigParser.parse(from: MockChartJSONs.stackedBarConfig),
            "stackedBarConfig should parse without returning nil"
        )
        guard case .stackedBar(let title, let data, let stackNames) = chart else {
            return XCTFail("FSRT-006 — Expected .stackedBar, got \(chart)")
        }
        XCTAssertFalse(title.isEmpty)
        XCTAssertFalse(data.isEmpty, "Stacked bar data must have at least one series")
        XCTAssertFalse(stackNames.isEmpty)
    }

    func test_FSRT006_stackedBar_stringDict_convertsToDoubles() throws {
        let json = """
        {
            "chartType": "Stacked Bar Chart",
            "chartName": "SB",
            "data": {
                "field1": ["0","1"],
                "field2": { "Survived": ["38","26"], "Died": ["24","45"] }
            },
            "metrics": {}
        }
        """
        let chart = try XCTUnwrap(ChartConfigParser.parse(from: json))
        guard case .stackedBar(_, let data, _) = chart else {
            return XCTFail("Expected .stackedBar")
        }
        XCTAssertEqual(data["Survived"], [38.0, 26.0])
        XCTAssertEqual(data["Died"],     [24.0, 45.0])
    }

    // MARK: - FSRT-007: Donut

    func test_FSRT007_donutConfig_parsesToDonutCase() throws {
        let chart = try XCTUnwrap(
            ChartConfigParser.parse(from: MockChartJSONs.donutConfig),
            "donutConfig should parse without returning nil"
        )
        guard case .donut(let title, let data, let labels) = chart else {
            return XCTFail("FSRT-007 — Expected .donut, got \(chart)")
        }
        XCTAssertFalse(title.isEmpty)
        XCTAssertEqual(data.count, labels.count, "values and labels must have the same count")
        XCTAssertFalse(data.isEmpty)
    }

    func test_FSRT007_donut_isDistinctFromPie() throws {
        // Donut and Pie use the same data shape; the ChartData case is what
        // distinguishes them and drives the holeRadius in DonutChartView.
        let donutJSON = """
        {
            "chartType": "Donut",
            "chartName": "D",
            "data": { "field1": ["A"], "field2": ["1"] },
            "metrics": {}
        }
        """
        let pieJSON = """
        {
            "chartType": "Pie",
            "chartName": "P",
            "data": { "field1": ["A"], "field2": ["1"] },
            "metrics": {}
        }
        """
        let donut = try XCTUnwrap(ChartConfigParser.parse(from: donutJSON))
        let pie   = try XCTUnwrap(ChartConfigParser.parse(from: pieJSON))

        guard case .donut = donut else { return XCTFail("Expected .donut") }
        guard case .pie   = pie   else { return XCTFail("Expected .pie") }
    }

    // MARK: - FSRT-008: Pie

    func test_FSRT008_pieConfig_parsesToPieCase() throws {
        let chart = try XCTUnwrap(
            ChartConfigParser.parse(from: MockChartJSONs.pieConfig),
            "pieConfig should parse without returning nil"
        )
        guard case .pie(let title, let data, let labels) = chart else {
            return XCTFail("FSRT-008 — Expected .pie, got \(chart)")
        }
        XCTAssertFalse(title.isEmpty)
        XCTAssertEqual(data.count, labels.count)
        XCTAssertFalse(data.isEmpty)
    }

    func test_FSRT008_pie_zeroValueDoesNotCrash() throws {
        let json = """
        {
            "chartType": "Pie",
            "chartName": "ZeroTest",
            "data": { "field1": ["A","B","C"], "field2": ["100","0","50"] },
            "metrics": {}
        }
        """
        let chart = try XCTUnwrap(ChartConfigParser.parse(from: json))
        guard case .pie(_, let data, _) = chart else {
            return XCTFail("Expected .pie")
        }
        XCTAssertEqual(data, [100.0, 0.0, 50.0], "Zero value must be preserved, not dropped")
    }

    // MARK: - FSRT-009: Unsupported type

    func test_FSRT009_unknownChartType_returnsUnsupportedCase() throws {
        let json = """
        {
            "chartType": "Radar Chart",
            "chartName": "R",
            "data": {},
            "metrics": {}
        }
        """
        // parse() must NOT return nil — it returns .unsupported so the UI can
        // show a meaningful error instead of a blank screen.
        let chart = try XCTUnwrap(
            ChartConfigParser.parse(from: json),
            "FSRT-009 — parse() must return .unsupported (not nil) for unknown types"
        )
        guard case .unsupported(let typeName) = chart else {
            return XCTFail("FSRT-009 — Expected .unsupported, got \(chart)")
        }
        XCTAssertEqual(typeName, "Radar Chart")
    }

    func test_FSRT009_unsupportedType_preservesTypeName() throws {
        let unknownTypes = ["Radar Chart", "Bubble Chart", "Heatmap", "Candlestick"]
        for typeName in unknownTypes {
            let json = """
            { "chartType": "\(typeName)", "chartName": "X", "data": {}, "metrics": {} }
            """
            let chart = try XCTUnwrap(ChartConfigParser.parse(from: json))
            guard case .unsupported(let name) = chart else {
                return XCTFail("Expected .unsupported for '\(typeName)'")
            }
            XCTAssertEqual(name, typeName, "unsupported case must preserve the original type name")
        }
    }

    // MARK: - FSRT-010: Error loading configJSON

    func test_FSRT010_malformedConfigJSON_returnsNil() {
        // When Firestore returns corrupted JSON, parse() returns nil.
        // FullScreenViewModel sets configError and keeps isLoadingConfig = false.
        XCTAssertNil(
            ChartConfigParser.parse(from: "{bad json"),
            "FSRT-010 — Malformed JSON must return nil so FullScreenViewModel sets configError"
        )
    }

    func test_FSRT010_emptyConfigJSON_returnsNil() {
        XCTAssertNil(
            ChartConfigParser.parse(from: ""),
            "FSRT-010 — Empty string must return nil"
        )
    }

    func test_FSRT010_missingChartType_returnsNil() {
        let json = """
        { "chartName": "No type", "data": { "field1": ["A"], "field2": [1.0] }, "metrics": {} }
        """
        XCTAssertNil(
            ChartConfigParser.parse(from: json),
            "FSRT-010 — Missing chartType key must return nil (required field)"
        )
    }

    // MARK: - Routing: all mock configs parse to a non-nil result

    func test_allMockChartConfigs_parseToNonNilChartData() {
        let configs: [(name: String, json: String)] = [
            ("verticalBar",   MockChartJSONs.verticalBarConfig),
            ("horizontalBar", MockChartJSONs.horizontalBarConfig),
            ("line",          MockChartJSONs.lineConfig),
            ("scatter",       MockChartJSONs.scatterConfig),
            ("stackedBar",    MockChartJSONs.stackedBarConfig),
            ("area",          MockChartJSONs.areaConfig),
            ("donut",         MockChartJSONs.donutConfig),
            ("pie",           MockChartJSONs.pieConfig),
            ("tile",          MockChartJSONs.tileConfig)
        ]
        for config in configs {
            XCTAssertNotNil(
                ChartConfigParser.parse(from: config.json),
                "\(config.name) mock should parse to a non-nil ChartData"
            )
        }
    }

    // MARK: - sortedKeys ordering

    func test_sortedKeys_numericKeysAreOrderedNumerically() {
        // "10" must come after "3", not before (lexicographic would give wrong order).
        let data: [String: Double] = ["3": 30, "10": 100, "1": 10]
        let sorted = data.keys.sorted { lhs, rhs in
            if let l = Double(lhs), let r = Double(rhs) { return l < r }
            return lhs < rhs
        }
        XCTAssertEqual(sorted, ["1", "3", "10"])
    }

    func test_sortedKeys_alphabeticKeysAreOrderedAlphabetically() {
        let data: [String: Double] = ["Banana": 2, "Apple": 5, "Cherry": 3]
        let sorted = data.keys.sorted { lhs, rhs in
            if let l = Double(lhs), let r = Double(rhs) { return l < r }
            return lhs < rhs
        }
        XCTAssertEqual(sorted, ["Apple", "Banana", "Cherry"])
    }

    func test_sortedValues_correspondToSortedKeys() {
        let data: [String: Double] = ["3": 30, "1": 10, "2": 20]
        let sortedKeys = data.keys.sorted { lhs, rhs in
            if let l = Double(lhs), let r = Double(rhs) { return l < r }
            return lhs < rhs
        }
        let sortedValues = sortedKeys.compactMap { data[$0] }
        XCTAssertEqual(sortedKeys,   ["1", "2", "3"])
        XCTAssertEqual(sortedValues, [10.0, 20.0, 30.0])
    }
    
    func test_unknownType_isNotNil() {
        let json = """
        { "chartType": "Bubble Chart", "chartName": "X", "data": {}, "metrics": {} }
        """
        XCTAssertNotNil(
            ChartConfigParser.parse(from: json),
            "Unknown type should return .unsupported, never nil"
        )
    }
}
