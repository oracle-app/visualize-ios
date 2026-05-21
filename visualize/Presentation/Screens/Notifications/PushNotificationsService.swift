//
//  PushNotificationService.swift
//  visualize
//
//  Created by Miguel Degollado 
//

import UIKit
import UserNotifications
import FirebaseMessaging
import FirebaseAuth

@MainActor
final class PushNotificationService: NSObject {

    private let saveFCMTokenUseCase: SaveFCMTokenUseCase
    private weak var coordinator: AppCoordinator?

    init(saveFCMTokenUseCase: SaveFCMTokenUseCase, coordinator: AppCoordinator) {
        self.saveFCMTokenUseCase = saveFCMTokenUseCase
        self.coordinator = coordinator
        super.init()
    }

    func setup() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        requestAuthorisation()
    }

    private func requestAuthorisation() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error { print("[PushService] Auth error: \(error.localizedDescription)"); return }
            guard granted else { return }
            DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
        }
    }

    private func persistToken(_ fcmToken: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Task {
            try? await saveFCMTokenUseCase.execute(token: fcmToken, userID: userID)
        }
    }

    private func handleDeepLink(from userInfo: [AnyHashable: Any]) {
        guard let destination = userInfo["destination"] as? String else { return }
        Task { @MainActor [weak self] in
            if destination == "notifications" { self?.coordinator?.navigateToNotifications() }
        }
    }
}

extension PushNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        handleDeepLink(from: response.notification.request.content.userInfo)
        completionHandler()
    }
}

extension PushNotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        persistToken(fcmToken)
    }
}
EOF
