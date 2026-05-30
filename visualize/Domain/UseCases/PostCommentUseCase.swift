//
//  PostCommentUseCase.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation

final class PostCommentUseCase {
    private let repository: CommentRepository

    init(repository: CommentRepository = CommentRepositoryImpl()) {
        self.repository = repository
    }

    func execute(visualizationID: String, author: AppUser, content: String, imageURL: String? = nil) async throws {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || imageURL != nil else {
            throw CommentError.emptyContent
        }
        try await repository.postComment(
            visualizationID: visualizationID,
            author: author,
            content: content,
            imageURL: imageURL
        )
    }
}
