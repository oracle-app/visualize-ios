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

    func notificationsStream(for userID: String) -> AsyncStream<[Notification]> {
        let raw = datasource.notificationsStream(for: userID)
        return AsyncStream { continuation in
            let task = Task {
                for await result in raw {
                    guard !Task.isCancelled else { break }
                    switch result {
                    case .success(let dtos):
                        continuation.yield(dtos.map { $0.toDomain() })
                    case .failure:
                        continuation.yield([])
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func unreadStream(for userID: String) -> AsyncStream<Bool> {
        datasource.unreadStream(for: userID)
    }

    func markAsRead(notificationID: String) async throws {
        try await datasource.markAsRead(notificationID: notificationID)
    }

    func markAllAsRead(userID: String) async throws {
        try await datasource.markAllAsRead(userID: userID)
    }
}
