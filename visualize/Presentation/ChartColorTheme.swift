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
            return [AppColors.Palette.Lagoon.c1, AppColors.Palette.Lagoon.c2, AppColors.Palette.Lagoon.c3, AppColors.Palette.Lagoon.c4, AppColors.Palette.Lagoon.c5]
        case .sunset:
            return [AppColors.Palette.Sunset.c1, AppColors.Palette.Sunset.c2, AppColors.Palette.Sunset.c3, AppColors.Palette.Sunset.c4, AppColors.Palette.Sunset.c5]
        case .harvest:
            return [AppColors.Palette.Harvest.c1, AppColors.Palette.Harvest.c2, AppColors.Palette.Harvest.c3, AppColors.Palette.Harvest.c4, AppColors.Palette.Harvest.c5]
        case .petal:
            return [AppColors.Palette.Petal.c1, AppColors.Palette.Petal.c2, AppColors.Palette.Petal.c3, AppColors.Palette.Petal.c4, AppColors.Palette.Petal.c5]
        }
    }

    var uiColors: [UIColor] {
        swiftUIColors.map { UIColor($0) }
    }
}
