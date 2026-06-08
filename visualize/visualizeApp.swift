//
//  visualizeApp.swift
//  visualize
//
//  Created by Carlos Amador on 11/04/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import SciChart

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
      ) -> Bool {
          if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
              FirebaseApp.configure()
          }
      
        #if DEBUG
          guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
              assertionFailure("GoogleService-Info.plist is missing — Firebase will not be configured. Add the file to the project.")
              return true
          }
          
          AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #endif
          
          return true
      }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return AppDelegate.orientationLock
    }
}

@main
struct VisualizeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init() {
        let key = Bundle.main.infoDictionary?["SCICHART_LICENSE_KEY"] as? String ?? ""
        SCIChartSurface.setRuntimeLicenseKey(key)
    }
    var body: some Scene {
        WindowGroup {
            rootView
        }
    }

    @ViewBuilder
    private var rootView: some View {
        #if DEBUG
        let args = CommandLine.arguments
        if args.contains("-uitest-snip-editor") {
            SnipEditorScreen(
                chartImage: UIImage(systemName: "chart.bar.fill") ?? UIImage(),
                onPost: { _, _ in },
                onDismiss: {}
            )
        } else if args.contains("-uitest-snip-comment") {
            SnipCommentSampleView()
        } else if args.contains("-uitest-teams-list") {
            NavigationStack {
                TeamsScreen(
                    viewModel: TeamsScreenViewModel(
                        teamRepository: MockTeamRepository(),
                        authRepository: MockAuthRepository(),
                        userRepository: MockUserRepository()
                    )
                )
                .environment(AppCoordinator())
            }
        } else if args.contains("-uitest-profile") {
            NavigationStack {
                ProfileScreen(
                    logoutUseCase: MockLogoutUseCase(),
                    getCurrentUserProfileUseCase: MockGetCurrentUserProfileUseCase(),
                    uploadProfilePhotoUseCase: MockUploadProfilePhotoUseCase(),
                    deleteProfilePhotoUseCase: MockDeleteProfilePhotoUseCase()
                )
                .environment(AppCoordinator())
            }
        } else {
            defaultRoot
        }
        #else
        defaultRoot
        #endif
    }

    private var defaultRoot: some View {
        RootScreen(
            viewModel: RootViewModel(
                authRepository: AuthRepositoryImpl(
                    source: AuthFirebaseDatasource()
                ),
                userRepository: UserRepositoryImpl(userDatasource: UserDatasource())
            ),
            coordinator: AppCoordinator()
        )
    }
}
