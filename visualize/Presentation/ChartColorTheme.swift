//
//  ChartColorTheme.swift
//  visualize
//
//  Created by Zuleyca Soto on 20/05/26.
//

import SwiftUI

enum ChartColorTheme: String, CaseIterable, Identifiable {
    case aqua
    case iris
    case autumn
    case blossom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .aqua: "Aqua"
        case .iris: "Iris"
        case .autumn: "Autumn"
        case .blossom: "Blossom"
        }
    }

    var swiftUIColors: [Color] {
        switch self {
        case .aqua:
            [.paletteAqua1, .paletteAqua2, .paletteAqua3, .paletteAqua4, .paletteAqua5]
        case .iris:
            [.paletteIris1, .paletteIris2, .paletteIris3, .paletteIris4, .paletteIris5]
        case .autumn:
            [.paletteAutumn1, .paletteAutumn2, .paletteAutumn3, .paletteAutumn4, .paletteAutumn5]
        case .blossom:
            [.paletteBlossom1, .paletteBlossom2, .paletteBlossom3, .paletteBlossom4, .paletteBlossom5]
        }
    }

    var uiColors: [UIColor] {
        swiftUIColors.map { UIColor($0) }
    }
}
