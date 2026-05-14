//
//  CommentRepositoryImpl.swift
//  visualize
//

import Foundation
import FirebaseFirestore

final class CommentRepositoryImpl: CommentRepository {

    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    func postSnipComment(visualizationID: String, authorID: String, imageURL: URL) async throws {
        let data: [String: Any] = [
            "authorID": authorID,
            "content": "",
            "createdAt": Timestamp(),
            "imageURL": imageURL.absoluteString
        ]

        try await db
            .collection("visualizations")
            .document(visualizationID)
            .collection("comments")
            .addDocument(data: data)
    }
}
