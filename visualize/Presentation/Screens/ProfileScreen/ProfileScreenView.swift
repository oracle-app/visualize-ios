//
//  ProfileScreenView.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 27/04/26.
//

import SwiftUI

struct ProfileScreenView: View {
    // MARK: - State properties

    @State private var viewModel: ProfileScreenViewModel = .init()

    // MARK: - Internal properties

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Metrics.sectionSpacing) {
                    ProfileHeaderView() {
                        viewModel.editProfilePhoto()
                    }

                    VStack(spacing: Metrics.contentSpacing) {
                        ProfileUserInfoView(
                            username: viewModel.username,
                            email: viewModel.email
                        )

                        Divider()
                            .background(Color.appSubtitle.opacity(Metrics.dividerOpacity))

                        ProfilePreferencesSectionView(
                            availableThemes: viewModel.availableChartThemes,
                            selectedTheme: viewModel.selectedChartTheme
                        ) { theme in
                            viewModel.selectChartTheme(theme)
                        }

                        Divider()
                            .background(Color.appSubtitle.opacity(Metrics.dividerOpacity))

                        ProfileAboutSectionView(aboutItems: viewModel.aboutItems)

                        Button("Log out", action: viewModel.logOut)
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Metrics.buttonVerticalPadding)
                            .background {
                                RoundedRectangle(cornerRadius: Metrics.buttonCornerRadius)
                                    .stroke(.red.opacity(Metrics.borderOpacity), lineWidth: Metrics.borderWidth)
                            }
                    }
                    .padding(.horizontal, Metrics.horizontalPadding)
                    .padding(.bottom, Metrics.bottomPadding)
                }
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    static let sectionSpacing: CGFloat = 14
    static let contentSpacing: CGFloat = 24
    static let horizontalPadding: CGFloat = 24
    static let bottomPadding: CGFloat = 24
    static let buttonVerticalPadding: CGFloat = 10
    static let buttonCornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 1
    static let borderOpacity: CGFloat = 0.8
    static let dividerOpacity: CGFloat = 0.2
}

#Preview {
    ProfileScreenView()
}
