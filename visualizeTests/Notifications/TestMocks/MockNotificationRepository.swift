//
//  MockNotificationRepository.swift
//  visualize
//
//  Created by Ruben Castro on 09/06/26.
//

#if DEBUG
import Foundation

// MARK: - NotificationsMockNotificationRepository
/// Mock implementation of NotificationRepository for the notifications UI
/// test scene (`-uitest-notifications-loaded`). Emits a hardcoded list of
/// `Notification` domain models through the same `AsyncStream` contract the
/// real repository uses, so `NotificationsScreen` renders through its actual
/// pipeline (grouping, display mapping, layout) without a Firestore
/// connection.
///
/// The bodies are crafted so `NotificationDisplayMapper`'s sender-name
/// extraction produces the exact strings asserted by `NOTI-001`:
///   "Nico commented on your visualization."
///   "Ana shared a visualization with you."

final class NotificationsMockNotificationRepository: NotificationRepository {

    func notificationsStream(for userID: String) -> AsyncStream<Result<[Notification], Error>> {
        AsyncStream { continuation in
            continuation.yield(.success(fixture))
            continuation.finish()
        }
    }

    func unreadStream(for userID: String) -> AsyncStream<Bool> {
        AsyncStream { continuation in
            continuation.yield(fixture.contains { !$0.isRead })
            continuation.finish()
        }
    }

    func markAsRead(notificationID: String) async throws {}

    func markAllAsRead(userID: String) async throws {}

    // MARK: - Fixture

    private var fixture: [Notification] {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        return [
            Notification(
                id: "notification-today-1",
                body: "Nico commented on your visualization.",
                createdAt: today,
                isRead: false,
                receiverID: "preview-user-id",
                senderProfilePictureURL: nil,
                type: "thread_reply"
            ),
            Notification(
                id: "notification-yesterday-1",
                body: "Ana shared a visualization with you.",
                createdAt: yesterday,
                isRead: true,
                receiverID: "preview-user-id",
                senderProfilePictureURL: nil,
                type: "visualization_shared"
            )
        ]
    }
}
#endif
