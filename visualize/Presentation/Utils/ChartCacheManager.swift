//
//  ChartCacheManager.swift
//  visualize
//
//  Created by Carlos Amador on 20/05/26.
//

import Foundation

class ChartDataWrapper {
    let chart: ChartData
    init(chart: ChartData) {
        self.chart = chart
    }
}

class ChartCacheManager {
    static let shared = ChartCacheManager()
    private let cache = NSCache<NSString, ChartDataWrapper>()
    
    private init() {
        cache.countLimit = 50
    }
    
    func getChart(for id: String) -> ChartData? {
        return cache.object(forKey: id as NSString)?.chart
    }
    
    func saveChart(_ chart: ChartData, for id: String) {
        let wrapper = ChartDataWrapper(chart: chart)
        cache.setObject(wrapper, forKey: id as NSString)
    }
}
