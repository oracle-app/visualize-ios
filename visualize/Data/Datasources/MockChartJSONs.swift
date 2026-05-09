//
//  MockChartJSONs.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 06/05/26.
//

/// Static catalog of mock JSON strings that simulate responses from the ML microservice.
///
/// All examples use the Titanic dataset, each highlighting a different dimension of the data.
/// The remaining static properties (horizontalBar, scatterFare, donut, tile) are kept here
/// for future use when their renderers are implemented.
enum MockChartJSONs {
    /// The 5 charts shown in VizReady. Only includes types with a working renderer.
    static let allCharts: [String] = [
        verticalBar,
        scatterAge,
        stackedBar,
        line,
        pie
    ]

    // MARK: - Chart 0 · Vertical Bar
    /// Survival Rate by Passenger Class
    static let verticalBar: String = """
    {
        "chartIndex": 0,
        "chartName": "Survival Rate by Passenger Class",
        "chartType": "Vertical Bar Chart",
        "data": {
            "field1": ["1", "2", "3"],
            "field2": ["107", "93", "218"]
        },
        "metrics": { "field1": "Pclass", "field2": "Survived" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 3
    }
    """
    
    // MARK: - Chart 1 · Horizontal Bar (renderer pending)
    /// Average Fare by Passenger Class
    static let horizontalBar: String = """
    {
        "chartIndex": 1,
        "chartName": "Average Fare by Passenger Class",
        "chartType": "Horizontal Bar Chart",
        "data": {
            "field1": ["1", "2", "3"],
            "field2": ["94.28", "22.20", "12.46"]
        },
        "metrics": { "field1": "Pclass", "field2": "Fare" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 3
    }
    """
    
    // MARK: - Chart 2 · Scatter (Fare). Not in allCharts, kept for reference
    /// Survival Rate by Fare Category
    static let scatterFare: String = """
    {
        "chartIndex": 2,
        "chartName": "Survival Rate by Fare Category",
        "chartType": "Scatter",
        "data": {
            "field1": ["7.83","7.0","9.69","8.66","12.29","9.23","7.63","29.0",
                       "7.23","24.15","7.90","26.0","82.27","26.0","61.18","27.72",
                       "12.35","7.23","7.93","7.23","59.4","3.17","31.68","61.38",
                       "262.38","14.5","61.98","7.23","30.5","21.68","26.0","31.5",
                       "20.58","23.45","57.75","7.23","8.05","8.66","9.5","56.50",
                       "13.42","26.55","7.85","13.0","52.55","7.93","29.7","7.75",
                       "76.29","15.9","60.0","15.03","23.0","263.0","15.58","29.13",
                       "7.90","7.65","16.1","262.38","7.90","13.5","7.75","7.73",
                       "262.38","21.0","7.88","42.4","28.54","263.0","7.75","7.90",
                       "7.93","27.72","211.5","211.5","8.05","25.7","13.0","7.75",
                       "15.25","221.78","26.0","7.90","10.71","14.45","7.88"],
            "field2": ["0","1","0","0","1","0","1","0","1","0","0","0","1","0","1","1",
                       "0","0","1","1","0","0","1","0","1","0","1","0","0","0","0","0",
                       "1","1","0","0","1","1","0","0","0","0","0","1","1","0","0","0",
                       "1","1","0","0","1","1","0","0","0","0","0","1","0","0","0","1",
                       "0","1","1","0","0","1","1","0","1","0","1","0","0","1","0","1",
                       "0","0","0","0","0","0","1"]
        },
        "metrics": { "field1": "Fare", "field2": "Survived" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 87
    }
    """
    
    // MARK: - Chart 3 · Stacked Bar
    /// Survival Rate by Family Size (SibSp).
        /// field2 keys: survival status (0 = died, 1 = survived).
        /// Values are counts per SibSp bucket matching field1 order.
    static let stackedBar: String = """
    {
        "chartIndex": 3,
        "chartName": "Survival Rate by Family Size",
        "chartType": "Stacked Bar Chart",
        "data": {
            "field1": ["0", "1", "2", "3", "4", "5", "8"],
            "field2": {
                "0": [374, 72, 43, 8, 15, 5, 7],
                "1": [163, 89, 36, 7, 0, 0, 0]
            }
        },
        "metrics": { "field1": "SibSp", "field2": "Survived", "field3": "Pclass" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 7
    }
    """
    
    // MARK: - Chart 4 · Scatter (Age)
    /// Age Distribution vs Survival
    static let scatterAge: String = """
    {
        "chartIndex": 4,
        "chartName": "Age Distribution vs Survival",
        "chartType": "Scatter",
        "data": {
            "field1": ["34.5","47.0","62.0","27.0","22.0","14.0","30.0","26.0","18.0","21.0",
                       "46.0","23.0","63.0","47.0","24.0","35.0","21.0","27.0","45.0","55.0",
                       "9.0","21.0","48.0","50.0","22.0","22.5","41.0","50.0","24.0","33.0",
                       "30.0","18.5","21.0","25.0","39.0","41.0","30.0","45.0","25.0","45.0",
                       "60.0","36.0","24.0","27.0","20.0","28.0","10.0","35.0","25.0","36.0",
                       "17.0","32.0","18.0","22.0","13.0","18.0","47.0","31.0","60.0","24.0",
                       "21.0","29.0","28.5","35.0","32.5","55.0","30.0","24.0","6.0","67.0",
                       "49.0","27.0","18.0","2.0","22.0","27.0","25.0","25.0","76.0","29.0",
                       "20.0","33.0","43.0","27.0","26.0","16.0","28.0","21.0"],
            "field2": ["0","1","0","0","1","0","1","0","1","0",
                       "0","1","0","1","1","0","0","1","1","0",
                       "0","0","1","0","1","0","0","0","0","1",
                       "0","0","1","0","0","0","1","1","0","0",
                       "1","1","0","0","1","1","0","0","0","1",
                       "0","0","0","1","0","1","0","0","1","1",
                       "0","1","0","1","0","1","0","1","0","0",
                       "0","1","1","0","1","1","0","0","1","0",
                       "1","0","1","0","0","1","0","0"]
        },
        "metrics": { "field1": "Age", "field2": "Survived" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 88
    }
    """
    
    // MARK: - Chart 5 · Line
    /// Average Fare per Age Group
    static let line: String = """
    {
        "chartIndex": 5, "chartName": "Average Fare per Age Group",
        "chartType": "Line",
        "data": {
            "field1": ["5","10","15","20","25","30","35","40","45","50","55","60","65","70"],
            "field2": ["38.5","42.1","28.7","21.3","27.9","35.6","48.2","62.4","71.0","55.3","44.8","63.7","40.2","35.9"]
        },
        "metrics": { "field1": "Age", "field2": "Avg Fare" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 14
    }
    """
    
    // MARK: - Chart 6 · Pie
    /// Passenger Sex Distribution
    static let pie: String = """
    {
        "chartIndex": 6, "chartName": "Passenger Sex Distribution",
        "chartType": "Pie",
        "data": { "field1": ["Male","Female"], "field2": ["577","314"] },
        "metrics": { "field1": "Sex", "field2": "Count" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 2
    }
    """
    
    // MARK: - Chart 7 · Donut (renderer pending)
    /// Embarkation Port Distribution
    static let donut: String = """
    {
        "chartIndex": 7, "chartName": "Embarkation Port Distribution",
        "chartType": "Donut",
        "data": {
            "field1": ["Southampton","Cherbourg","Queenstown"],
            "field2": ["644","168","77"]
        },
        "metrics": { "field1": "Embarked", "field2": "Count" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 3
    }
    """
    
    // MARK: - Chart 8 · Tile (renderer pending)
    /// Total Passengers KPI
    static let tile: String = """
    {
        "chartIndex": 8, "chartName": "Total Passengers",
        "chartType": "Tile",
        "data": { "field1": ["891"], "field2": [] },
        "metrics": { "field1": "Count" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 1
    }
    """
}
