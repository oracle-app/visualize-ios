//
//  ProfileScreenView.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 27/04/26.
//

import SwiftUI

struct ProfileScreenView: View {
    // MARK: - State properties

    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: ProfileScreenViewModel

    // MARK: - Initialization

    init(
        logoutUseCase: LogoutUseCase,
        getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase
    ) {
        _viewModel = State(initialValue: ProfileScreenViewModel(
            logoutUseCase: logoutUseCase,
            getCurrentUserProfileUseCase: getCurrentUserProfileUseCase
        ))
    }

    // MARK: - Internal properties

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Metrics.sectionSpacing) {
                    ProfileHeaderView(profilePictureURL: viewModel.profilePictureURL) {
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

                        ProfileAboutSectionView(items: viewModel.aboutItems)

                        Button("Log out", action: viewModel.logOut)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Metrics.buttonVerticalPadding)
                            .background {
                                Capsule()
                                    .fill(Color.appBackground)
                                    .shadow(color: .black.opacity(Metrics.shadowOpacity), radius: Metrics.shadowRadius, x: 0, y: Metrics.shadowY)
                            }
                            .overlay {
                                Capsule()
                                    .strokeBorder(.red, lineWidth: Metrics.borderWidth)
                            }
                    }
                    .padding(.horizontal, Metrics.horizontalPadding)
                }
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .onAppear {
                viewModel.loadProfile()
            }
            .onChange(of: viewModel.isLoggedOut) { _, loggedOut in
                if loggedOut {
                    coordinator.replace(path: [])
                }
            }
        }
    }
}

// MARK: - Metrics

private enum Metrics {
    static let sectionSpacing: CGFloat = 14
    static let contentSpacing: CGFloat = 30
    static let horizontalPadding: CGFloat = 32
    static let buttonVerticalPadding: CGFloat = 10
    static let borderWidth: CGFloat = 1
    static let dividerOpacity: CGFloat = 0.2
    static let shadowOpacity: CGFloat = 0.25
    static let shadowRadius: CGFloat = 5
    static let shadowY: CGFloat = 2
}

#Preview {
    let authRepo = AuthRepositoryImpl(source: AuthFirebaseDatasource())
    let userRepo = UserRepositoryImpl(userDatasource: UserDatasource())
    ProfileScreenView(
        logoutUseCase: LogoutUseCase(repository: authRepo),
        getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase(
            authRepository: authRepo,
            userRepository: userRepo
        )
    )
    .environment(AppCoordinator())
}
