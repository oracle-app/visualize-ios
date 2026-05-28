//
//  DeleteCommentUseCase.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation

final class DeleteCommentUseCase {
    private let repository: CommentRepository

    init(repository: CommentRepository = CommentRepositoryImpl()) {
        self.repository = repository
    }

    func execute(visualizationID: String, commentID: String, requestingUserID: String, authorID: String) async throws {
        guard requestingUserID == authorID else {
            throw CommentError.unauthorized
        }
        try await repository.deleteComment(
            visualizationID: visualizationID,
            commentID: commentID
        )
    }
}
