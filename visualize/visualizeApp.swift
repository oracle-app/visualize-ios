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
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()

    #if DEBUG
    guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
      return true
    }

    AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
    #endif

    return true
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
            RootScreen(
                viewModel: RootViewModel(
                    authRepository: AuthRepositoryImpl(
                        source: AuthFirebaseDatasource()
                    )
                ),
                coordinator: AppCoordinator()
            )
        }
    }
}
