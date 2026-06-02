//
//  PostSnipCommentUseCase.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//
//
//  Domain use case that finalizes Snipping Tool sharing. It creates the Firestore
//  comment document that references the uploaded snip image URL, delegating the
//  persistence details to `CommentRepository`.

import Foundation

/// Saves a snip comment document to Firestore after the image has been uploaded to Storage.
struct PostSnipCommentUseCase {

    private let commentRepository: any CommentRepository

    init(commentRepository: any CommentRepository) {
        self.commentRepository = commentRepository
    }

    /// - Parameters:
    ///   - visualizationID: The Firestore document ID of the visualization.
    ///   - authorID: The UID of the user posting the snip.
    ///   - imageURL: The Firebase Storage download URL returned by `UploadSnipUseCase`.
    ///   - authorName: The display name of the user posting the snip.
    func execute(visualizationID: String, authorID: String, imageURL: URL, authorName: String) async throws {
        try await commentRepository.postSnipComment(
            visualizationID: visualizationID,
            authorID: authorID,
            imageURL: imageURL,
            authorName: authorName
        )
    }
}
