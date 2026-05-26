//
//  MarkNotificationsUseCase.swift
//  visualize
//
//  Created by Miguel Degollado on 20/05/26.


import Foundation

final class MarkNotificationReadUseCase {
    private let repository: NotificationRepository
    init(repository: NotificationRepository) { self.repository = repository }

    func execute(notificationID: String) async throws {
        try await repository.markAsRead(notificationID: notificationID)
    }
}
