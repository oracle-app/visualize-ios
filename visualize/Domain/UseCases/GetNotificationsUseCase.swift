//
//  GetNotificationsUseCase.swift
//  visualize
//
//  Created by SOPORTE on 20/05/26.

Import Foundation

final class GetNotificationsUseCase {
    private let repository: NotificationRepository
    init(repository: NotificationRepository) { self.repository = repository }
    func execute(for userID: String) -> AsyncStream<[NotificationDisplayGroup]> {
        repository.notificationsStream(for: userID)
    }
}

