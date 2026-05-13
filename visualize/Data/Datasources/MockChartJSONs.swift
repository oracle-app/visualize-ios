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
/// All examples use the Titanic dataset.
enum MockChartJSONs {
 
    // MARK: - Active suggestions
 
    /// Pairs consumed by `MockChartSuggestionsDatasource`. Each tuple is (config, preview).
    static let allCharts: [(config: String, preview: String)] = [
        (config: verticalBarConfig,  preview: verticalBarPreview),
        (config: scatterConfig,   preview: scatterPreview),
        (config: stackedBarConfig,   preview: stackedBarPreview),
        (config: lineConfig,         preview: linePreview),
        (config: pieConfig,          preview: piePreview),
    ]
 
    // MARK: - Chart 0 · Vertical Bar
 
    /// Survivors by Age Decade , 8 categories (full for FullScreenView)
    static let verticalBarConfig: String = """
    {
        "chartIndex": 0,
        "chartName": "Survival Rate by Passenger Class",
        "chartType": "Vertical Bar Chart",
        "data": {
            "field1": ["0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70+"],
            "field2": ["38", "26", "77", "87", "47", "28", "14", "2"]
        },
        "metrics": { "field1": "Age Group", "field2": "Survived" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 8
    }
    """
 
    /// Survivors by Passenger Class , 3 categories (reduced for card preview)
    /// Pclass 1: 136 survived, Pclass 2: 87 survived, Pclass 3: 119 survived
    static let verticalBarPreview: String = """
    {
        "chartIndex": 0,
        "chartName": "Survival Rate by Passenger Class",
        "chartType": "Vertical Bar Chart",
        "data": {
            "field1": ["1", "2", "3"],
            "field2": ["136", "87", "119"]
        },
        "metrics": { "field1": "Pclass", "field2": "Survived" },
        "page": 0, "pageSize": 100, "preview": true,
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
            "field2": ["84.15", "20.66", "13.68"]
        },
        "metrics": { "field1": "Pclass", "field2": "Avg Fare" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 3
    }
    """
 
    // MARK: - Chart 2 · Scatter Age
 
    /// Age Distribution vs Survival , all 88 passengers with known age (full for FullScreenView)
    static let scatterConfig: String = """
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
 
    /// Age Distribution vs Survival , 15 points (reduced for card preview)
    static let scatterPreview: String = """
    {
        "chartIndex": 4,
        "chartName": "Age Distribution vs Survival",
        "chartType": "Scatter",
        "data": {
            "field1": ["34.5","47.0","62.0","27.0","22.0","14.0","30.0","26.0","18.0","21.0",
                       "46.0","23.0","63.0","47.0","24.0"],
            "field2": ["0","1","0","0","1","0","1","0","1","0","0","1","0","1","1"]
        },
        "metrics": { "field1": "Age", "field2": "Survived" },
        "page": 0, "pageSize": 100, "preview": true,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 15
    }
    """
 
    // MARK: - Chart 3 · Stacked Bar
 
    /// Survived/Died by Parch , 7 categories (full for FullScreenView)
    /// Parch 0: 678 total (233 survived, 445 died)
    /// Parch 1: 118 total (65 survived, 53 died)
    /// Parch 2: 80 total (40 survived, 40 died)
    /// Parch 3-6: small groups
    static let stackedBarConfig: String = """
    {
        "chartIndex": 3,
        "chartName": "Survival Rate by Family Size",
        "chartType": "Stacked Bar Chart",
        "data": {
            "field1": ["0", "1", "2", "3", "4", "5", "6"],
            "field2": {
                "0": [445, 53, 40, 2, 4, 4, 1],
                "1": [233, 65, 40, 3, 0, 1, 0]
            }
        },
        "metrics": { "field1": "Parch", "field2": "Survived", "field3": "Pclass" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 7
    }
    """
 
    /// Survived/Died by SibSp , 7 categories (reduced for card preview)
    /// SibSp 0: 608 total (210 survived, 398 died)
    /// SibSp 1: 209 total (112 survived, 97 died)
    static let stackedBarPreview: String = """
    {
        "chartIndex": 3,
        "chartName": "Survival Rate by Family Size",
        "chartType": "Stacked Bar Chart",
        "data": {
            "field1": ["0", "1", "2", "3", "4", "5", "8"],
            "field2": {
                "0": [398, 97, 15, 12, 15, 5, 7],
                "1": [210, 112, 13, 4, 3, 0, 0]
            }
        },
        "metrics": { "field1": "SibSp", "field2": "Survived", "field3": "Pclass" },
        "page": 0, "pageSize": 100, "preview": true,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 7
    }
    """
 
    // MARK: - Chart 4 · Line
 
    /// Average Fare by Age , 17 points every 5 years from age 5 to 85 (full for FullScreenView)
    static let lineConfig: String = """
    {
        "chartIndex": 5,
        "chartName": "Average Fare per Age Group",
        "chartType": "Line",
        "data": {
            "field1": ["5","10","15","20","25","30","35","40","45","50","55","60","65","70","75","80","85"],
            "field2": ["27.4","19.8","24.6","26.3","31.2","40.5","52.1","65.8","58.3","49.7","41.2","55.6","38.9","32.4","21.1","15.3","9.8"]
        },
        "metrics": { "field1": "Age", "field2": "Avg Fare" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 17
    }
    """
 
    /// Average Fare by Age , 8 points every 10 years (reduced for card preview)
    static let linePreview: String = """
    {
        "chartIndex": 5,
        "chartName": "Average Fare per Age Group",
        "chartType": "Line",
        "data": {
            "field1": ["10","20","30","40","50","60","70","80"],
            "field2": ["19.8","26.3","40.5","65.8","49.7","55.6","32.4","15.3"]
        },
        "metrics": { "field1": "Age", "field2": "Avg Fare" },
        "page": 0, "pageSize": 100, "preview": true,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 8
    }
    """
 
    // MARK: - Chart 5 · Pie
 
    /// Passenger Count by Class and Sex , 6 segments (full for FullScreenView)
    /// 1st M: 94, 1st F: 122, 2nd M: 108, 2nd F: 76, 3rd M: 347, 3rd F: 144 → total 891
    static let pieConfig: String = """
    {
        "chartIndex": 6,
        "chartName": "Passenger Sex Distribution",
        "chartType": "Pie",
        "data": {
            "field1": ["1st-Male", "1st-Female", "2nd-Male", "2nd-Female", "3rd-Male", "3rd-Female"],
            "field2": ["94", "122", "108", "76", "347", "144"]
        },
        "metrics": { "field1": "Class & Sex", "field2": "Count" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 6
    }
    """
 
    /// Passenger Count by Sex , 2 segments (reduced for card preview)
    /// Male: 577, Female: 314 → total 891
    static let piePreview: String = """
    {
        "chartIndex": 6,
        "chartName": "Passenger Sex Distribution",
        "chartType": "Pie",
        "data": { "field1": ["Male", "Female"], "field2": ["577", "314"] },
        "metrics": { "field1": "Sex", "field2": "Count" },
        "page": 0, "pageSize": 100, "preview": true,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 2
    }
    """
 
    // MARK: - Chart 6 · Donut (not in allCharts)
 
    /// Survived/Died by Embarkation Port , 6 segments (full for FullScreenView)
    /// S: 217 survived 427 died, C: 93 survived 75 died, Q: 30 survived 47 died
    /// (2 passengers with missing port excluded , total 889)
    static let donutConfig: String = """
    {
        "chartIndex": 7,
        "chartName": "Embarkation Port Distribution",
        "chartType": "Donut",
        "data": {
            "field1": ["S-Survived", "S-Died", "C-Survived", "C-Died", "Q-Survived", "Q-Died"],
            "field2": ["217", "427", "93", "75", "30", "47"]
        },
        "metrics": { "field1": "Port & Outcome", "field2": "Count" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 6
    }
    """
 
    /// Passenger Count by Embarkation Port , 3 segments (reduced for card preview)
    /// Southampton: 644, Cherbourg: 168, Queenstown: 77 → total 889
    static let donutPreview: String = """
    {
        "chartIndex": 7,
        "chartName": "Embarkation Port Distribution",
        "chartType": "Donut",
        "data": {
            "field1": ["Southampton", "Cherbourg", "Queenstown"],
            "field2": ["644", "168", "77"]
        },
        "metrics": { "field1": "Embarked", "field2": "Count" },
        "page": 0, "pageSize": 100, "preview": true,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 3
    }
    """
 
    // MARK: - Chart 7 · Tile (renderer pending)
 
    /// Total Passengers KPI , full stat for FullScreenView
    static let tileConfig: String = """
    {
        "chartIndex": 8,
        "chartName": "Total Passengers",
        "chartType": "Tile",
        "data": { "field1": ["891"], "field2": [] },
        "metrics": { "field1": "Count" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 1
    }
    """
 
    /// Total Survivors KPI , reduced for card preview
    static let tilePreview: String = """
    {
        "chartIndex": 8,
        "chartName": "Total Passengers",
        "chartType": "Tile",
        "data": { "field1": ["342"], "field2": [] },
        "metrics": { "field1": "Survived" },
        "page": 0, "pageSize": 100, "preview": true,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 1
    }
    """
    
    // MARK: - Chart 8 · Area (renderer pending)
 
    /// Survivors and Deaths by Age Group, 8 groups (full for FullScreenView)
    static let areaConfig: String = """
    {
        "chartIndex": 9,
        "chartName": "Survival Trend by Age",
        "chartType": "Area",
        "data": {
            "field1": ["0-9","10-19","20-29","30-39","40-49","50-59","60-69","70+"],
            "field2": {
                "Survived": ["38","26","77","87","47","28","14","2"],
                "Died":     ["24","45","108","61","42","24","18","12"]
            }
        },
        "metrics": { "field1": "Age Group", "field2": "Count", "field3": "Outcome" },
        "page": 0, "pageSize": 5000, "preview": false,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 8
    }
    """
 
    /// Survivors and Deaths by Age Group, 4 groups (reduced for card preview)
    static let areaPreview: String = """
    {
        "chartIndex": 9,
        "chartName": "Survival Trend by Age",
        "chartType": "Area",
        "data": {
            "field1": ["0-19","20-39","40-59","60+"],
            "field2": {
                "Survived": ["64","164","75","16"],
                "Died":     ["69","169","66","30"]
            }
        },
        "metrics": { "field1": "Age Group", "field2": "Count", "field3": "Outcome" },
        "page": 0, "pageSize": 100, "preview": true,
        "status": "COMPLETED", "totalPages": 1, "totalPoints": 4
    }
    """
}
