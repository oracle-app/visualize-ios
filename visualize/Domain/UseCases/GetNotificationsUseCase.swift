//
//  GetNotificationsUseCase.swift
//  visualize
//
// created by Miguel Degollado

import Foundation

final class GetNotificationsUseCase {
    private let repository: NotificationRepository
    init(repository: NotificationRepository) { self.repository = repository }

    func execute(for userID: String) -> AsyncStream<[Notification]> {
        repository.notificationsStream(for: userID)
    }
}
