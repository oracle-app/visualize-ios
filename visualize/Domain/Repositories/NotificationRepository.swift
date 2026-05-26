//
//  NotificationRepository.swift
//  visualize
//
// created by Miguel Degollado


protocol NotificationRepository {
    func notificationsStream(for userID: String) -> AsyncStream<[Notification]>
    func unreadStream(for userID: String) -> AsyncStream<Bool>
    func markAsRead(notificationID: String) async throws
    func markAllAsRead(userID: String) async throws
}
