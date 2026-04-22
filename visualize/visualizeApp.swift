//
//  visualizeApp.swift
//  visualize
//
//  Created by Carlos Amador on 11/04/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // TODO: Remove this guard — GoogleService-Info.plist must be present in production. This is only for local development without Firebase credentials.
    guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
      return true
    }
    FirebaseApp.configure()

    return true
  }
}


@main
struct visualizeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
