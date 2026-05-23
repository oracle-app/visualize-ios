//
//  ChartColorTheme.swift
//  visualize
//
//  Created by Zuleyca Soto on 20/05/26.
//

import SwiftUI

enum ChartColorTheme: String, CaseIterable, Identifiable {
    case lagoon
    case sunset
    case harvest
    case petal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lagoon: "Lagoon"
        case .sunset: "Sunset"
        case .harvest: "Harvest"
        case .petal: "Petal"
        }
    }

    var swiftUIColors: [Color] {
        switch self {
        case .lagoon:
            [.paletteLagoon1, .paletteLagoon2, .paletteLagoon3, .paletteLagoon4, .paletteLagoon5]
        case .sunset:
            [.paletteSunset1, .paletteSunset2, .paletteSunset3, .paletteSunset4, .paletteSunset5]
        case .harvest:
            [.paletteHarvest1, .paletteHarvest2, .paletteHarvest3, .paletteHarvest4, .paletteHarvest5]
        case .petal:
            [.palettePetal1, .palettePetal2, .palettePetal3, .palettePetal4, .palettePetal5]
        }
    }

    var uiColors: [UIColor] {
        swiftUIColors.map { UIColor($0) }
    }
}
