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

    @AppStorage("selectedChartTheme") private var selectedThemeRaw: String = ChartColorTheme.lagoon.rawValue
    @State private var activeToast: Toast?

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

    // MARK: - Private

    private var selectedTheme: ChartColorTheme {
        ChartColorTheme(rawValue: selectedThemeRaw) ?? .lagoon
    }

    // MARK: - Body

    var body: some View {
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
                        availableThemes: ChartColorTheme.allCases,
                        selectedTheme: selectedTheme
                    ) { theme in
                        selectedThemeRaw = theme.rawValue
                        activeToast = Toast(
                            message: "\(theme.title) theme applied",
                            type: .success
                        )
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
                coordinator.logout()
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = activeToast {
                ToastView(toast: toast)
                    .padding(.bottom, Metrics.toastBottomPadding)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.4), value: activeToast)
        .appBackground()
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
    static let toastBottomPadding: CGFloat = 24
    static let toastDuration: TimeInterval = 2.5
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
