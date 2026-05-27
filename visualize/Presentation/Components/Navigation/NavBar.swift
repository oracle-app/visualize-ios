//
//  NavBar.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/15/26.
//

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
    private let notificationsViewModel: NotificationsViewModel

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
        let notifRepo = NotificationRepositoryImpl()
        self.notificationsViewModel = NotificationsViewModel(
            authRepository: authRepo,
            notificationRepository: notificationsRepo,
            
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
            // Feed
            NavigationStack(path: $coordinator.feedPath) {
                FeedView(viewModel: feedViewModel)
                    .navigationDestination(for: AppRoute.self) { route in
                        if case .notifications = route {
                            NotificationsScreen(viewModel: notificationsViewModel)
                        }
                    }
            }
            .tabItem { Label("", systemImage: "house") }
            .tag(Tabs.feed)

            // Create
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

            // Teams
            NavigationStack(path: $coordinator.teamsPath) {
                Color.green.ignoresSafeArea()
            }
            .tabItem { Label("", systemImage: "person.2") }
            .tag(Tabs.teams)

            // Profile
            NavigationStack(path: $coordinator.profilePath) {
                let authRepository = AuthRepositoryImpl(source: AuthFirebaseDatasource())
                let userRepository = UserRepositoryImpl(userDatasource: UserDatasource())

                let uploadProfilePhotoUseCase = UploadProfilePhotoUseCase(
                    authRepository: authRepository,
                    userRepository: userRepository
                )
                
                let deleteProfilePhotoUseCase = DeleteProfilePhotoUseCase(
                    authRepository: authRepository,
                    userRepository: userRepository
                )

                ProfileScreenView(
                    logoutUseCase: LogoutUseCase(repository: authRepository),
                    getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase(
                        authRepository: authRepository,
                        userRepository: userRepository
                    ),
                    uploadProfilePhotoUseCase: uploadProfilePhotoUseCase,
                    deleteProfilePhotoUseCase: deleteProfilePhotoUseCase
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
