//
//  CommentDatasource.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//

import FirebaseFirestore

/// Firestore datasource responsible for creating snip comment documents.
final class CommentDatasource {

    private let firebase: Firestore

    init(firebase: Firestore = Firestore.firestore()) {
        self.firebase = firebase
    }

    func postSnipComment(visualizationID: String, authorID: String, imageURL: URL, authorName: String) async throws {
        let data: [String: Any] = [
            "authorID": authorID,
            "authorName": authorName,
            "content": "",
            "createdAt": Timestamp(),
            "imageURL": imageURL.absoluteString
        ]

        try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .collection("comments")
            .addDocument(data: data)
    }
}
