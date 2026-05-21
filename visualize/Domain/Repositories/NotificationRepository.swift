//
//  NotificationRepository.swift
//  visualize
//
//  Created by Miguel Degollado on 20/05/26.
//

protocol NotificationRepository {
    func notificationsStream(for userID: String) -> AsyncStream<[NotificationDisplayGroup]>
    func markAsRead(notificationID: String, userID: String) async throws
    func markAllAsRead(userID: String) async throws
    func delete(notificationID: String, userID: String) async throws
    func saveFCMToken(_ token: String, for userID: String) async throws
    func removeFCMToken(for userID: String) async throws
}
