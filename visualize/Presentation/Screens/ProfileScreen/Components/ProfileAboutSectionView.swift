//
//  ProfileAboutSectionView.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 29/04/26.
//

import SwiftUI

struct ProfileAboutSectionView: View {
    // MARK: - Internal properties

    let aboutItems: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
            Label("About", systemImage: "info.circle.fill")
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.primaryText)

            VStack(alignment: .leading, spacing: Metrics.itemSpacing) {
                ForEach(aboutItems, id: \.self) { item in
                    Text(item)
                        .font(.caption)
                        .foregroundStyle(Color.appSubtitle)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Metrics

private enum Metrics {
    static let sectionSpacing: CGFloat = 8
    static let itemSpacing: CGFloat = 4
}

#Preview {
    ProfileAboutSectionView(aboutItems: [
        "Version: 1.0.0",
        "Developed by DreamTeam Corp.",
        "Terms of Service",
        "Licenses and open source libraries"
    ])
}
