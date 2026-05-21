//
//  DeleteNotificationUseCase.swift
//  visualize
//
//  Created by Miguel Degollado on 20/05/26.
//

import Foundation

final class DeleteNotificationUseCase {
    private let repository: NotificationRepository
    init(repository: NotificationRepository) { self.repository = repository }
    func execute(notificationID: String, userID: String) async throws {
        try await repository.delete(notificationID: notificationID, userID: userID)
    }
}
