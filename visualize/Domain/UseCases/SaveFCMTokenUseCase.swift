//
//  SaveFCMTokenUseCase.swift
//  visualize
//
//  Created by SOPORTE on 20/05/26.
//

import Foundation

final class SaveFCMTokenUseCase {
    private let repository: NotificationRepository
    init(repository: NotificationRepository) { self.repository = repository }
    func execute(token: String, userID: String) async throws {
        try await repository.saveFCMToken(token, for: userID)
    }
}

final class RemoveFCMTokenUseCase {
    private let repository: NotificationRepository
    init(repository: NotificationRepository) { self.repository = repository }
    func execute(userID: String) async throws {
        try await repository.removeFCMToken(for: userID)
    }
}
