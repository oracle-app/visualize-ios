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
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-uitest-snip-editor") {
            SnipEditorScreen(
                chartImage: UIImage(systemName: "chart.bar.fill") ?? UIImage(),
                onPost: { _, _ in },
                onDismiss: {}
            )
        } else if args.contains("-uitest-snip-comment") {
            SnipCommentSampleView()
        } else if args.contains("-feedState") {
                feedUITestRoot(args: args)
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
    
    
    // MARK: - Feed UI Test Root
    #if DEBUG
    /// Builds a standalone FeedScreen with a mock ViewModel for UI testing.
    /// Controlled entirely by launch arguments — no Firebase, no network calls.
    @ViewBuilder
    private func feedUITestRoot(args: [String]) -> some View {
        let vm = FeedScreenViewModel.uitestMock(args: args)
        NavigationStack {
            FeedScreen(viewModel: vm, shouldLoad: false)
                .environment(AppCoordinator())
        }
    }
    #endif
}
