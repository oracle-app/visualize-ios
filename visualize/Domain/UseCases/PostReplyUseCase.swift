//
//  PostReplyUseCase.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation

final class PostReplyUseCase {
    private let repository: CommentRepository

    init(repository: CommentRepository = CommentRepositoryImpl()) {
        self.repository = repository
    }

    func execute(visualizationID: String, commentID: String, author: AppUser, content: String) async throws {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CommentError.emptyContent
        }
        try await repository.postReply(
            visualizationID: visualizationID,
            commentID: commentID,
            author: author,
            content: content
        )
    }
}
