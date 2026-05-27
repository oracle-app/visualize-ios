//
//  LoadCommentsUseCase.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation

final class LoadCommentsUseCase {
    private let repository: CommentRepository

    init(repository: CommentRepository = CommentRepositoryImpl()) {
        self.repository = repository
    }

    func execute(visualizationID: String) async throws -> [Comment] {
        try await repository.loadComments(visualizationID: visualizationID)
    }
}
