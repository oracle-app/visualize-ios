//
//  CommentRepositoryImpl.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//

import Foundation

/// Concrete comment repository that persists snip comments through the comment datasource.
final class CommentRepositoryImpl: CommentRepository {

    private let commentDatasource: CommentDatasource

    init(commentDatasource: CommentDatasource = CommentDatasource()) {
        self.commentDatasource = commentDatasource
    }

    func postSnipComment(visualizationID: String, authorID: String, imageURL: URL, authorName: String) async throws {
        try await commentDatasource.postSnipComment(
            visualizationID: visualizationID,
            authorID: authorID,
            imageURL: imageURL,
            authorName: authorName
        )
    }
}
