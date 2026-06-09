//
//  ProfileAboutSectionView.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 29/04/26.
//

import SwiftUI

// MARK: - AboutItem

enum AboutItem: Identifiable {
    case info(String)
    case action(String, action: () -> Void)

    var id: String {
        switch self {
        case .info(let text): text
        case .action(let text, _): text
        }
    }
}

// MARK: - ProfileAboutSectionView

struct ProfileAboutSectionView: View {
    // MARK: - Internal properties

    let items: [AboutItem]

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
            Label("About", systemImage: "info.circle.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColors.Text.primary)

            VStack(alignment: .leading, spacing: Metrics.itemSpacing) {
                ForEach(items) { item in
                    switch item {
                    case .info(let text):
                        Text(text)
                            .foregroundStyle(AppColors.Text.secondary)
                    case .action(let text, let action):
                        Button(text, action: action)
                            .foregroundStyle(AppColors.Text.primary)
                    }
                }
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Metrics

private enum Metrics {
    static let sectionSpacing: CGFloat = 6
    static let itemSpacing: CGFloat = 0
}

#Preview {
    ZStack {
        Color.appBackground
            .ignoresSafeArea()

        ProfileAboutSectionView(items: [
            .info("Version 1.0.0"),
            .info("Developed by DreamTeam Corp."),
            .action("Terms of Service") { },
            .action("Licenses and open source libraries") { }
        ])
        .padding(.horizontal, 24)
    }
}
