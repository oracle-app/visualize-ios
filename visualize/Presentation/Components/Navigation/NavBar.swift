//
//  NavBar.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/15/26.

import SwiftUI

struct NavBar: View {
    @State private var selectedTab: Tabs = .feed
    @State private var feedViewModel: FeedViewModel = {
        let userDS = UserDatasource()
        let teamsDS = TeamDatasource()
        let visualizationDS = VisualizationDatasource(userDatasource: userDS, teamsDatasource: teamsDS)
        let repo = VisualizationRepositoryImpl(
            userDatasource: userDS,
            visualizationDatasource: visualizationDS,
            teamsDatasource: teamsDS
        )
        let userRepo = UserRepositoryImpl(userDatasource: userDS)
        return FeedViewModel(
            loadVisualizationsUseCase: LoadVisualizationsUseCase(visualizationRepository: repo),
            searchVisualizationsUseCase: SearchVisualizationsUseCase(visualizationRepository: repo),
            hideVisualizationUseCase: HideVisualizationUseCase(userRepository: userRepo, visualizationRepository: repo),
            deleteVisualizationUseCase: DeleteVisualizationUseCase(visualizationRepository: repo)
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
        TabView(selection: $selectedTab) {
            FeedView(viewModel: feedViewModel)
                .tabItem{
                    Label("", systemImage: "house")
                }
                .tag(Tabs.feed)
            CreateVisualization()
                .tabItem{
                    Label("", systemImage: "plus")
                }
                .tag(Tabs.create)
            Color.green.ignoresSafeArea()
                    .tabItem{
                    Label("", systemImage: "person.2")
                }
                .tag(Tabs.teams)
            ProfileScreenView(
                logoutUseCase: logoutUseCase,
                getCurrentUserProfileUseCase: getCurrentUserProfileUseCase
            )
                    .tabItem{
                    Label("",systemImage: "person.circle")
                }
                .tag(Tabs.profile)
        }
    }
}

#Preview {
    NavBar()
        .environment(AppCoordinator())
}
