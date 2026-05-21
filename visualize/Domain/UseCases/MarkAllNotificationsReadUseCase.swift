//
//  MarkAllNotificationsReadUseCase.swift
//  Created by Miguel Degollado
//

import Foundation

final class MarkAllNotificationsReadUseCase {
    private let repository: NotificationRepository
    init(repository: NotificationRepository) { self.repository = repository }
    func execute(userID: String) async throws {
        try await repository.markAllAsRead(userID: userID)
    }
}
