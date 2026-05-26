//
//  NotificationRepositoryImp.swift
//  visualize
//
//  Created by Miguel Degollado on 20/05/26.
//

import Foundation

final class NotificationRepositoryImpl: NotificationRepository {

    private let datasource: NotificationDatasource

    init(datasource: NotificationDatasource = NotificationDatasource()) {
        self.datasource = datasource
    }

    func notificationsStream(for userID: String) -> AsyncStream<[NotificationDisplayGroup]> {
        let raw = datasource.notificationsStream(for: userID)
        return AsyncStream { continuation in
            Task {
                for await dtos in raw {
                    continuation.yield(Self.group(dtos))
                }
                continuation.finish()
            }
        }
    }

    func markAsRead(notificationID: String, userID: String) async throws {
        try await datasource.markAsRead(notificationID: notificationID, userID: userID)
    }

    func markAllAsRead(userID: String) async throws {
        try await datasource.markAllAsRead(userID: userID)
    }

    func delete(notificationID: String, userID: String) async throws {
        try await datasource.delete(notificationID: notificationID, userID: userID)
    }

    func saveFCMToken(_ token: String, for userID: String) async throws {
        try await datasource.saveFCMToken(token, for: userID)
    }

    func removeFCMToken(for userID: String) async throws {
        try await datasource.removeFCMToken(for: userID)
    }

    private static func group(_ dtos: [NotificationDTO]) -> [NotificationDisplayGroup] {
        let calendar = Calendar.current
        let now = Date()
        var today: [NotificationDisplayItem] = []
        var yesterday: [NotificationDisplayItem] = []
        var last30: [NotificationDisplayItem] = []

        for dto in dtos {
            let item = dto.toDisplayItem()
            if calendar.isDateInToday(dto.createdAt) {
                today.append(item)
            } else if calendar.isDateInYesterday(dto.createdAt) {
                yesterday.append(item)
            } else if let days = calendar.dateComponents([.day], from: dto.createdAt, to: now).day, days <= 30 {
                last30.append(item)
            }
        }

        return [
            NotificationDisplayGroup(id: "Today",        items: today),
            NotificationDisplayGroup(id: "Yesterday",    items: yesterday),
            NotificationDisplayGroup(id: "Last 30 days", items: last30)
        ]
    }
}
