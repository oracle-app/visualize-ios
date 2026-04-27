//
//  Untitled.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

enum VisualizationFilter {
    case all
    case personal
    case shared
    
    var title: String {
            switch self {
            case .all:
                return "All Feed"
            case .personal:
                return "Personal Feed"
            case .shared:
                return "Shared Feed"
            }
        }
    
    
}
