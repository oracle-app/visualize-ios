//
//  NavBarView.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/15/26.
//

import SwiftUI

struct NavBarView: View {
    @Environment(AppCoordinator.self) private var coordinator

    @State private var feedViewModel: FeedScreenViewModel = {
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
        return FeedScreenViewModel(
            loadVisualizationsUseCase: LoadVisualizationsUseCase(visualizationRepository: repo),
            searchVisualizationsUseCase: SearchVisualizationsUseCase(visualizationRepository: repo),
            hideVisualizationUseCase: HideVisualizationUseCase(userRepository: userRepo, visualizationRepository: repo),
            deleteVisualizationUseCase: DeleteVisualizationUseCase(visualizationRepository: repo),
            authRepository: authRepository
        )
    }()

    private let logoutUseCase: LogoutUseCase
    private let getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase
    private let notificationsViewModel: NotificationsScreenViewModel

    init() {
        let authSource = AuthFirebaseDatasource()
        let authRepo = AuthRepositoryImpl(source: authSource)
        let userRepo = UserRepositoryImpl(userDatasource: UserDatasource())
        let notificationsRepo = NotificationRepositoryImpl(
            datasource: NotificationDatasource()
        )
        self.logoutUseCase = LogoutUseCase(repository: authRepo)
        self.getCurrentUserProfileUseCase = GetCurrentUserProfileUseCase(
            authRepository: authRepo,
            userRepository: userRepo
        )
        
        self.notificationsViewModel = NotificationsScreenViewModel(
            authRepository: authRepo,
            notificationRepository: notificationsRepo
        )

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.navbarIcon)
        appearance.stackedLayoutAppearance.normal.iconColor = .secondaryLabel
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {
            // Feed
            NavigationStack(path: $coordinator.feedPath) {
                FeedScreen(viewModel: feedViewModel)
                    .navigationDestination(for: AppRoute.self) { route in
                        if case .notifications = route {
                            NotificationsScreen(viewModel: notificationsViewModel)
                        }
                    }
            }
            .tabItem { Label("", systemImage: "house") }
            .tag(Tabs.feed)

            // Create (Logica de roles introducida aquí)
            if coordinator.currentUser?.role != .consumer {
                NavigationStack(path: $coordinator.createPath) {
                    CreateVisualizationScreen()
                        .navigationDestination(for: CreateRoute.self) { route in
                            switch route {
                            case .generatingVisualizations:
                                GeneratingVisualizationsScreen()
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
            }

            // Teams
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
                .navigationDestination(for: TeamsRoute.self) { route in
                    switch route {
                    case .createTeam:
                        CreateTeamScreen(
                            viewModel: CreateTeamViewModel(
                                createTeamUseCase: CreateTeamUseCase(
                                    teamRepository: TeamRepositoryImpl(
                                        teamDatasource: TeamDatasource(),
                                        userDatasource: UserDatasource()
                                    )
                                ),
                                userRepository: UserRepositoryImpl(
                                    userDatasource: UserDatasource()
                                ),
                                teamRepository: TeamRepositoryImpl(
                                    teamDatasource: TeamDatasource(),
                                    userDatasource: UserDatasource()
                                ),
                                authRepository: AuthRepositoryImpl(
                                    source: AuthFirebaseDatasource()
                                )
                            ),
                            onConfirm: {}
                        )
                        .navigationBarBackButtonHidden(true)
                    }
                }
            }
            .tabItem { Label("", systemImage: "person.2") }
            .tag(Tabs.teams)
