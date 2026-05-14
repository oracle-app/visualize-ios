//
//  CommentDatasource.swift
//  visualize
//

import FirebaseFirestore

final class CommentDatasource {

    private let firebase: Firestore

    init(firebase: Firestore = Firestore.firestore()) {
        self.firebase = firebase
    }

    func postSnipComment(visualizationID: String, authorID: String, imageURL: URL) async throws {
        let data: [String: Any] = [
            "authorID": authorID,
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
