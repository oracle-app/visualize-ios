//
//  NavBar.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/15/26.

import SwiftUI

struct NavBar: View {
    @Environment(AppCoordinator.self) private var coordinator

    @State private var feedViewModel: FeedViewModel = {
        let userDS = UserDatasource()
        let teamsDS = TeamDatasource()
        let authDS = AuthFirebaseDatasource()
        let visualizationDS = VisualizationDatasource(userDatasource: userDS, teamsDatasource: teamsDS)
        let repo = VisualizationRepositoryImpl(
            userDatasource: userDS,
            visualizationDatasource: visualizationDS,
            teamsDatasource: teamsDS
        )
        let authRepository = AuthRepositoryImpl(source: authDS)
        let userRepo = UserRepositoryImpl(userDatasource: userDS)
        return FeedViewModel(
            loadVisualizationsUseCase: LoadVisualizationsUseCase(visualizationRepository: repo),
            searchVisualizationsUseCase: SearchVisualizationsUseCase(visualizationRepository: repo),
            hideVisualizationUseCase: HideVisualizationUseCase(userRepository: userRepo, visualizationRepository: repo),
            deleteVisualizationUseCase: DeleteVisualizationUseCase(visualizationRepository: repo),
            authRepository: authRepository
        )
    }()

    private let logoutUseCase: LogoutUseCase
    private let getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase

    init() {
        let authSource = AuthFirebaseDatasource()
        let authRepo = AuthRepositoryImpl(source: authSource)
        let userRepo = UserRepositoryImpl(userDatasource: UserDatasource())
        self.logoutUseCase = LogoutUseCase(repository: authRepo)
        self.getCurrentUserProfileUseCase = GetCurrentUserProfileUseCase(
            authRepository: authRepo,
            userRepository: userRepo
        )

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.stackedLayoutAppearance.selected.iconColor = .systemMint
        appearance.stackedLayoutAppearance.normal.iconColor = .black
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {
            NavigationStack(path: $coordinator.feedPath) {
                FeedView(viewModel: feedViewModel)
            }
            .tabItem { Label("", systemImage: "house") }
            .tag(Tabs.feed)

            NavigationStack(path: $coordinator.createPath) {
                CreateVisualization()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .generatingVisualizations:
                            GeneratingVisualizationsView()
                                .navigationBarBackButtonHidden(true)

                        case .vizReady:
                            VizReadyView(suggestions: coordinator.pendingSuggestions)
                                .navigationBarBackButtonHidden(true)

                        default:
                            EmptyView()
                        }
                    }
            }
            .tabItem { Label("", systemImage: "plus") }
            .tag(Tabs.create)

            NavigationStack(path: $coordinator.teamsPath) {
                TeamsScreen(
                    viewModel: TeamsScreenViewModel(
                        teamRepository: TeamRepositoryImpl(
                            teamDatasource: TeamDatasource(),
                            userDatasource: UserDatasource()
                        ),
                        authRepository: AuthRepositoryImpl(
                            source: AuthFirebaseDatasource()
                        ),
                        userRepository: UserRepositoryImpl(
                            userDatasource: UserDatasource()
                        )
                    )
                )
            }
            .tabItem { Label("", systemImage: "person.2") }
            .tag(Tabs.teams)

            NavigationStack(path: $coordinator.profilePath) {
                ProfileScreenView(
                    logoutUseCase: logoutUseCase,
                    getCurrentUserProfileUseCase: getCurrentUserProfileUseCase
                )
            }
            .tabItem { Label("", systemImage: "person.circle") }
            .tag(Tabs.profile)
        }
    }
}

#Preview {
    NavBar()
        .environment(AppCoordinator())
}
