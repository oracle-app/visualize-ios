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
        } else if args.contains("-uitest-notifications-loaded") {
            NotificationsUITestLoadedView()
        } else if args.contains("-uitest-notifications-empty") {
            NotificationsEmptyView()
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

#if DEBUG
private struct NotificationsUITestLoadedView: View {
    private let groups: [NotificationDisplayGroup] = [
        NotificationDisplayGroup(
            id: "Today",
            items: [
                NotificationDisplayItem(
                    id: "notification-today-1",
                    boldPrefix: "Nico ",
                    message: "commented on your visualization.",
                    timestamp: Date(),
                    isRead: false,
                    avatarInitials: "NP",
                    avatarColor: Color.appTeal
                )
            ]
        ),
        NotificationDisplayGroup(
            id: "Yesterday",
            items: [
                NotificationDisplayItem(
                    id: "notification-yesterday-1",
                    boldPrefix: "Ana ",
                    message: "shared a visualization with you.",
                    timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                    isRead: true,
                    avatarInitials: "AR",
                    avatarColor: Color.primaryOrange
                )
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(groups) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(group.title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.appNavy)
                                .padding(.horizontal, 24)

                            NotificationGroupCardView(group: group)
                                .padding(.horizontal, 24)
                        }
                    }

                    Text("No more notifications.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.appSubtitle)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
                .padding(.bottom, 100)
            }
            .background(Color.appBackground)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
#endif
