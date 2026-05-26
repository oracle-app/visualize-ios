//
//  ObserveUnreadNotifications.swift
//  visualize
//
//  Created by Miguel Degollado on 26/05/26.
//



import Foundation

final class ObserveUnreadNotificationsUseCase {
    private let repository: NotificationRepository
    init(repository: NotificationRepository) { self.repository = repository }

    func execute(for userID: String) -> AsyncStream<Bool> {
        repository.unreadStream(for: userID)
    }
}
