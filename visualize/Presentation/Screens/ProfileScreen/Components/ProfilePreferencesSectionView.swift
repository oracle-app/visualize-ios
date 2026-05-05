//
//  ProfilePreferencesSectionView.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 27/04/26.
//

import SwiftUI

struct ProfilePreferencesSectionView: View {
    // MARK: - Internal properties

    let availableThemes: [ChartColorTheme]
    let selectedTheme: ChartColorTheme
    let selectThemeAction: (ChartColorTheme) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
            Label("Chart theme", systemImage: "paintpalette.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.primaryText)

            LazyVGrid(columns: columns, spacing: Metrics.rowSpacing) {
                ForEach(availableThemes) { theme in
                    Button(theme.title) {
                        selectThemeAction(theme)
                    }
                    .labelStyle(.iconOnly)
                    .frame(height: Metrics.themeHeight)
                    .background {
                        ThemePaletteView(colors: colors(for: theme))
                    }
                    .clipShape(.rect(cornerRadius: Metrics.themeCornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: Metrics.themeCornerRadius)
                            .strokeBorder(
                                selectedTheme == theme ? Color.primaryText : Color.clear,
                                lineWidth: Metrics.selectedBorderWidth
                            )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Private properties

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: Metrics.columnSpacing),
            GridItem(.flexible(), spacing: Metrics.columnSpacing)
        ]
    }

    // MARK: - Private methods

    /// Returns the visual color palette for a chart theme.
    /// - Parameter theme: The chart color theme to render.
    /// - Returns: The SwiftUI colors associated with the selected theme.
    private func colors(for theme: ChartColorTheme) -> [Color] {
        switch theme {
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
}

// MARK: - ThemePaletteView

private struct ThemePaletteView: View {
    // MARK: - Internal properties

    let colors: [Color]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(colors.indices, id: \.self) { index in
                colors[index]
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    static let sectionSpacing: CGFloat = 8
    static let themeHeight: CGFloat = 22
    static let themeCornerRadius: CGFloat = 7
    static let selectedBorderWidth: CGFloat = 2
    static let rowSpacing: CGFloat = 8
    static let columnSpacing: CGFloat = 8
}

#Preview {
    ZStack {
        Color.appBackground
            .ignoresSafeArea()

        ProfilePreferencesSectionView(
            availableThemes: ChartColorTheme.allCases,
            selectedTheme: .aqua
        ) { _ in
            // Preview action
        }
        .padding(.horizontal, 24)
    }
}
