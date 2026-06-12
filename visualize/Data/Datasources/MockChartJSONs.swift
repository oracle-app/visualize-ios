//
//  MockChartJSONs.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 06/05/26.
//

/// Static catalog of mock JSON strings that simulate responses from the ML microservice.
/// Each entry in `allCharts` is a `(config, preview)` pair:
/// - `config`, full data for `FullScreenView` (all data points)
/// - `preview`, reduced data for card previews and the feed (fewer points, faster render)
///

enum MockChartJSONs {

    static let allCharts: [(config: String, preview: String)] = [
        (config: verticalBarConfig, preview: verticalBarPreview),
        (config: scatterConfig, preview: scatterPreview),
        (config: lineConfig, preview: linePreview),
        (config: pieConfig, preview: piePreview),
        (config: tileConfig, preview: tilePreview)
    ]

    // MARK: - verticalBar
    static let verticalBarConfig: String = """
    {
    "chartIndex": 0,
    "chartName": "Revenue Drop by Region",
    "chartType": "Vertical Bar Chart",
    "data": {
        "field1": [
            "Northwest",
            "Northeast",
            "Bajio",
            "West",
            "Central",
            "South"
        ],
        "field2": [
            "-12.8",
            "-5.4",
            "3.1",
            "-2.6",
            "4.8",
            "-9.7"
        ]
    },
    "metrics": {
        "field1": "Region",
        "field2": "Revenue Change %"
    },
    "page": 0,
    "pageSize": 5000,
    "preview": false,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 6
    }
    """

    static let verticalBarPreview: String = """
    {
    "chartIndex": 0,
    "chartName": "Revenue Drop by Region",
    "chartType": "Vertical Bar Chart",
    "data": {
        "field1": [
            "Northwest",
            "Northeast",
            "Central",
            "South"
        ],
        "field2": [
            "-12.8",
            "-5.4",
            "4.8",
            "-9.7"
        ]
    },
    "metrics": {
        "field1": "Region",
        "field2": "Revenue Change %"
    },
    "page": 0,
    "pageSize": 100,
    "preview": true,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 4
    }
    """

    // MARK: - horizontalBar
    static let horizontalBarConfig: String = """
    {
    "chartIndex": 1,
    "chartName": "Delayed Routes by Distribution Center",
    "chartType": "Horizontal Bar Chart",
    "data": {
        "field1": [
            "Hermosillo DC",
            "Monterrey DC",
            "Guadalajara DC",
            "Queretaro DC",
            "Merida DC",
            "Puebla DC",
            "Tijuana DC"
        ],
        "field2": [
            "48",
            "31",
            "27",
            "18",
            "24",
            "16",
            "39"
        ]
    },
    "metrics": {
        "field1": "Distribution Center",
        "field2": "Delayed Routes"
    },
    "page": 0,
    "pageSize": 5000,
    "preview": false,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 7
    }
    """

    static let horizontalBarPreview: String = """
    {
    "chartIndex": 1,
    "chartName": "Delayed Routes by Distribution Center",
    "chartType": "Horizontal Bar Chart",
    "data": {
        "field1": [
            "Hermosillo DC",
            "Tijuana DC",
            "Monterrey DC",
            "Guadalajara DC"
        ],
        "field2": [
            "48",
            "39",
            "31",
            "27"
        ]
    },
    "metrics": {
        "field1": "Distribution Center",
        "field2": "Delayed Routes"
    },
    "page": 0,
    "pageSize": 100,
    "preview": true,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 4
    }
    """

    // MARK: - scatter
    static let scatterConfig: String = """
    {
    "chartIndex": 2,
    "chartName": "Promotion Spend vs Sales Lift",
    "chartType": "Scatter",
    "data": {
        "field1": [
            "12",
            "18",
            "22",
            "25",
            "30",
            "34",
            "38",
            "42",
            "45",
            "49",
            "53",
            "58",
            "62",
            "67",
            "72"
        ],
        "field2": [
            "3.2",
            "4.5",
            "4.8",
            "5.1",
            "6.2",
            "6.9",
            "7.1",
            "7.4",
            "7.9",
            "8.0",
            "8.2",
            "8.5",
            "8.6",
            "8.7",
            "8.8"
        ]
    },
    "metrics": {
        "field1": "Promotion Spend K",
        "field2": "Sales Lift %"
    },
    "page": 0,
    "pageSize": 5000,
    "preview": false,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 15
    }
    """

    static let scatterPreview: String = """
    {
    "chartIndex": 2,
    "chartName": "Promotion Spend vs Sales Lift",
    "chartType": "Scatter",
    "data": {
        "field1": [
            "12",
            "25",
            "38",
            "49",
            "62",
            "72"
        ],
        "field2": [
            "3.2",
            "5.1",
            "7.1",
            "8.0",
            "8.6",
            "8.8"
        ]
    },
    "metrics": {
        "field1": "Promotion Spend K",
        "field2": "Sales Lift %"
    },
    "page": 0,
    "pageSize": 100,
    "preview": true,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 6
    }
    """

    // MARK: - stackedBar
    static let stackedBarConfig: String = """
    {
    "chartIndex": 3,
    "chartName": "Returned Units by Cause",
    "chartType": "Stacked Bar Chart",
    "data": {
        "field1": [
            "White Bread",
            "Tortillas",
            "Sweet Rolls",
            "Snack Cakes",
            "Buns"
        ],
        "field2": {
            "Expired": [
                "120",
                "94",
                "76",
                "88",
                "42"
            ],
            "Damaged": [
                "65",
                "41",
                "52",
                "39",
                "28"
            ],
            "Late Delivery": [
                "82",
                "59",
                "44",
                "71",
                "35"
            ]
        }
    },
    "metrics": {
        "field1": "Product",
        "field2": "Returned Units",
        "field3": "Cause"
    },
    "page": 0,
    "pageSize": 5000,
    "preview": false,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 5
    }
    """

    static let stackedBarPreview: String = """
    {
    "chartIndex": 3,
    "chartName": "Returned Units by Cause",
    "chartType": "Stacked Bar Chart",
    "data": {
        "field1": [
            "White Bread",
            "Tortillas",
            "Snack Cakes",
            "Buns"
        ],
        "field2": {
            "Expired": [
                "120",
                "94",
                "88",
                "42"
            ],
            "Damaged": [
                "65",
                "41",
                "39",
                "28"
            ],
            "Late Delivery": [
                "82",
                "59",
                "71",
                "35"
            ]
        }
    },
    "metrics": {
        "field1": "Product",
        "field2": "Returned Units",
        "field3": "Cause"
    },
    "page": 0,
    "pageSize": 100,
    "preview": true,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 4
    }
    """

    // MARK: - line
    static let lineConfig: String = """
    {
    "chartIndex": 4,
    "chartName": "Hourly Order Volume",
    "chartType": "Line",
    "data": {
        "field1": [
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12",
            "13",
            "14",
            "15",
            "16",
            "17",
            "18"
        ],
        "field2": [
            "420",
            "610",
            "870",
            "980",
            "1040",
            "1180",
            "1290",
            "1225",
            "1160",
            "1085",
            "970",
            "860",
            "690"
        ]
    },
    "metrics": {
        "field1": "Hour",
        "field2": "Orders"
    },
    "page": 0,
    "pageSize": 5000,
    "preview": false,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 13
    }
    """

    static let linePreview: String = """
    {
    "chartIndex": 4,
    "chartName": "Hourly Order Volume",
    "chartType": "Line",
    "data": {
        "field1": [
            "6",
            "8",
            "10",
            "12",
            "14",
            "16",
            "18"
        ],
        "field2": [
            "420",
            "870",
            "1040",
            "1290",
            "1160",
            "970",
            "690"
        ]
    },
    "metrics": {
        "field1": "Hour",
        "field2": "Orders"
    },
    "page": 0,
    "pageSize": 100,
    "preview": true,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 7
    }
    """

    // MARK: - pie
    static let pieConfig: String = """
    {
    "chartIndex": 5,
    "chartName": "Issue Share by Category",
    "chartType": "Pie",
    "data": {
        "field1": [
            "Late Delivery",
            "Inventory Gap",
            "Expired Product",
            "Damaged Package",
            "Order Error"
        ],
        "field2": [
            "34",
            "22",
            "18",
            "15",
            "11"
        ]
    },
    "metrics": {
        "field1": "Issue Category",
        "field2": "Share %"
    },
    "page": 0,
    "pageSize": 5000,
    "preview": false,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 5
    }
    """

    static let piePreview: String = """
    {
    "chartIndex": 5,
    "chartName": "Issue Share by Category",
    "chartType": "Pie",
    "data": {
        "field1": [
            "Late Delivery",
            "Inventory Gap",
            "Expired Product",
            "Other"
        ],
        "field2": [
            "34",
            "22",
            "18",
            "26"
        ]
    },
    "metrics": {
        "field1": "Issue Category",
        "field2": "Share %"
    },
    "page": 0,
    "pageSize": 100,
    "preview": true,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 4
    }
    """

    // MARK: - donut
    static let donutConfig: String = """
    {
    "chartIndex": 6,
    "chartName": "Customer Segment Mix",
    "chartType": "Donut",
    "data": {
        "field1": [
            "Small Retailers",
            "Convenience Chains",
            "Supermarkets",
            "Wholesale",
            "Online"
        ],
        "field2": [
            "31",
            "28",
            "24",
            "12",
            "5"
        ]
    },
    "metrics": {
        "field1": "Customer Segment",
        "field2": "Share %"
    },
    "page": 0,
    "pageSize": 5000,
    "preview": false,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 5
    }
    """

    static let donutPreview: String = """
    {
    "chartIndex": 6,
    "chartName": "Customer Segment Mix",
    "chartType": "Donut",
    "data": {
        "field1": [
            "Small Retailers",
            "Convenience",
            "Supermarkets",
            "Other"
        ],
        "field2": [
            "31",
            "28",
            "24",
            "17"
        ]
    },
    "metrics": {
        "field1": "Customer Segment",
        "field2": "Share %"
    },
    "page": 0,
    "pageSize": 100,
    "preview": true,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 4
    }
    """

    // MARK: - tile
    static let tileConfig: String = """
    {
    "chartIndex": 7,
    "chartName": "Incident Snapshot",
    "chartType": "Tile",
    "data": {
        "field1": [
            "Revenue Change",
            "Delayed Routes",
            "Return Rate",
            "At-Risk SKUs",
            "Top Issue",
            "Priority"
        ],
        "field2": [
            "-12.8%",
            "48",
            "8.7%",
            "14",
            "Late Delivery",
            "High"
        ]
    },
    "metrics": {
        "field1": "Metric",
        "field2": "Value"
    },
    "page": 0,
    "pageSize": 5000,
    "preview": false,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 6
    }
    """

    static let tilePreview: String = """
    {
    "chartIndex": 7,
    "chartName": "Incident Snapshot",
    "chartType": "Tile",
    "data": {
        "field1": [
            "Revenue Change",
            "Delayed Routes",
            "Return Rate",
            "Priority"
        ],
        "field2": [
            "-12.8%",
            "48",
            "8.7%",
            "High"
        ]
    },
    "metrics": {
        "field1": "Metric",
        "field2": "Value"
    },
    "page": 0,
    "pageSize": 100,
    "preview": true,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 4
    }
    """

    // MARK: - area
    static let areaConfig: String = """
    {
    "chartIndex": 8,
    "chartName": "Demand vs Available Stock",
    "chartType": "Area",
    "data": {
        "field1": [
            "Mon",
            "Tue",
            "Wed",
            "Thu",
            "Fri",
            "Sat",
            "Sun"
        ],
        "field2": {
            "Demand": [
                "6800",
                "7200",
                "7650",
                "8100",
                "8950",
                "9300",
                "8800"
            ],
            "Available Stock": [
                "7100",
                "7350",
                "7200",
                "7600",
                "7900",
                "8050",
                "7700"
            ]
        }
    },
    "metrics": {
        "field1": "Day",
        "field2": "Units",
        "field3": "Series"
    },
    "page": 0,
    "pageSize": 5000,
    "preview": false,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 7
    }
    """

    static let areaPreview: String = """
    {
    "chartIndex": 8,
    "chartName": "Demand vs Available Stock",
    "chartType": "Area",
    "data": {
        "field1": [
            "Mon",
            "Wed",
            "Fri",
            "Sun"
        ],
        "field2": {
            "Demand": [
                "6800",
                "7650",
                "8950",
                "8800"
            ],
            "Available Stock": [
                "7100",
                "7200",
                "7900",
                "7700"
            ]
        }
    },
    "metrics": {
        "field1": "Day",
        "field2": "Units",
        "field3": "Series"
    },
    "page": 0,
    "pageSize": 100,
    "preview": true,
    "status": "COMPLETED",
    "totalPages": 1,
    "totalPoints": 4
    }
    """

}
