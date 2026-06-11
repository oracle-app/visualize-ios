//
//  ProfileUserInfoView.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 28/04/26.
//

import SwiftUI

struct ProfileUserInfoView: View {
    // MARK: - Internal properties

    let username: String
    let email: String

    var body: some View {
        VStack(spacing: Metrics.spacing) {
            Text(username)
                .font(.title)
                .bold()
                .foregroundStyle(AppColors.Text.primary)
                .accessibilityIdentifier("ProfileUsername")

            Text(email)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.Text.secondary)
                .accessibilityIdentifier("ProfileEmail")
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Metrics

private enum Metrics {
    static let spacing: CGFloat = 4
}

#Preview {
    ProfileUserInfoView(username: "Diana Escalante", email: "diana@gmail.com")
}
