//
//  Untitled.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//
import Foundation

enum VisualizationFilter: CaseIterable {
    case all
    case personal
    case shared
    
    var title: String {
        switch self {
        case .all:
            String(localized: "All Feed")
        case .personal:
            String(localized: "Personal Feed")
        case .shared:
            String(localized: "Shared Feed")
        }
    }
    
}
