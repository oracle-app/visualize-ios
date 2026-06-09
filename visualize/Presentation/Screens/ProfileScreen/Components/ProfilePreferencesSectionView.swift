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
                .foregroundStyle(AppColors.Text.primary)

            LazyVGrid(columns: columns, spacing: Metrics.rowSpacing) {
                ForEach(availableThemes) { theme in
                    Button {
                        selectThemeAction(theme)
                    } label: {
                        ThemePaletteView(colors: theme.swiftUIColors)
                            .frame(maxWidth: .infinity)
                            .frame(height: Metrics.paletteHeight)
                            .clipShape(.rect(cornerRadius: Metrics.themeCornerRadius))
                            .overlay {
                                if selectedTheme == theme {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: Metrics.themeCornerRadius)
                                            .strokeBorder(AppColors.Text.primary, lineWidth: Metrics.selectedBorderWidth)
                                        RoundedRectangle(cornerRadius: Metrics.themeCornerRadius)
                                            .inset(by: Metrics.selectedBorderWidth)
                                            .strokeBorder(Color.appBackground, lineWidth: Metrics.selectionPadding)
                                    }
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(theme.title)
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
}

// MARK: - ThemePaletteView

private struct ThemePaletteView: View {
    // MARK: - Internal properties

    let colors: [Color]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(colors.indices, id: \.self) { index in
                Rectangle()
                    .fill(colors[index])
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    static let sectionSpacing: CGFloat = 14
    static let paletteHeight: CGFloat = 33
    static let themeCornerRadius: CGFloat = 10
    static let selectedBorderWidth: CGFloat = 2
    static let selectionPadding: CGFloat = 3
    static let rowSpacing: CGFloat = 8
    static let columnSpacing: CGFloat = 8
}

#Preview {
    ZStack {
        Color.appBackground
            .ignoresSafeArea()

        ProfilePreferencesSectionView(
            availableThemes: ChartColorTheme.allCases,
            selectedTheme: .lagoon
        ) { _ in
            // Preview action
        }
        .padding(.horizontal, 24)
    }
}
