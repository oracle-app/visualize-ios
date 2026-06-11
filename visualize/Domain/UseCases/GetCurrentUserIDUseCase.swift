//
//  GetCurrentUserIdUseCase.swift
//  visualize
//
//  Created by Miguel Degollado on 26/05/26.

import Foundation

/// Abstracts current-user lookup from the Presentation layer.
/// ViewModels call this instead of importing FirebaseAuth directly.
final class GetCurrentUserIDUseCase {
    private let authRepository: AuthRepository
    init(authRepository: AuthRepository) { self.authRepository = authRepository }

    func execute() -> String? {
        authRepository.getCurrentUser()?.uid
    }
}
