//
//  visualizeApp.swift
//  visualize
//
//  Created by Carlos Amador on 11/04/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import FirebaseMessaging
import SciChart

class AppDelegate: NSObject, UIApplicationDelegate {

    private var pushService: PushNotificationService?
    let coordinator = AppCoordinator()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }

        #if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #endif

        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            let repo = NotificationRepositoryImpl()

            // Wire RemoveFCMTokenUseCase into coordinator for logout cleanup
            coordinator.removeFCMTokenUseCase = RemoveFCMTokenUseCase(repository: repo)

            // Inject coordinator into PushNotificationService for deep links
            let service = PushNotificationService(
                saveFCMTokenUseCase: SaveFCMTokenUseCase(repository: repo),
                coordinator: coordinator
            )
            pushService = service
            service.setup()
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[AppDelegate] APNs registration failed: \(error.localizedDescription)")
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
                coordinator: delegate.coordinator
            )
        }
    }
}
