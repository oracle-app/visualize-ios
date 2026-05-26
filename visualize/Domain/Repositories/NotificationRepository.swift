//
//  NotificationRepository.swift
//  visualize
//
// created by Miguel Degollado

/// Domain repository contract for the notifications feature.
/// Returns pure domain entities — no display/presentation types.
protocol NotificationRepository {

    /// Live stream of domain Notification arrays ordered by recency.
    func notificationsStream(for userID: String) -> AsyncStream<[Notification]>

    /// Live stream emitting true when at least one unread notification exists.
    func unreadStream(for userID: String) -> AsyncStream<Bool>

    /// Marks a single notification as read.
    func markAsRead(notificationID: String, userID: String) async throws

    /// Marks all unread notifications as read via a batch write.
    func markAllAsRead(userID: String) async throws
}
