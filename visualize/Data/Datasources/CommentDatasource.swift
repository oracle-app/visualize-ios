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
    
    func fetchComments(visualizationID: String) async throws -> [CommentDTO] {
        let snapshot = try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .collection("comments")
            .order(by: "createdAt", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap {
            try? $0.data(as: CommentDTO.self)
        }
    }

    func postComment(visualizationID: String, authorID: String, authorName: String, content: String, imageURL: String? = nil) async throws {
        var data: [String: Any] = [
            "authorID": authorID,
            "authorName": authorName,
            "content": content,
            "createdAt": Timestamp()
        ]
        if let imageURL {
            data["imageURL"] = imageURL
        }

        try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .collection("comments")
            .addDocument(data: data)
    }

    func deleteComment(visualizationID: String, commentID: String) async throws {
        try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .collection("comments")
            .document(commentID)
            .delete()
    }

    // MARK: - Threads

    func fetchThreads(visualizationID: String, commentID: String) async throws -> [ThreadReplyDTO] {
        let snapshot = try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .collection("comments")
            .document(commentID)
            .collection("threads")
            .order(by: "createdAt", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap {
            try? $0.data(as: ThreadReplyDTO.self)
        }
    }

    func postReply(visualizationID: String, commentID: String, authorID: String, authorName: String, authorAvatarURL: String?, content: String) async throws {
        let data: [String: Any] = [
            "authorID": authorID,
            "authorName": authorName,
            "authorAvatarURL": authorAvatarURL ?? "",
            "content": content,
            "createdAt": Timestamp()
        ]

        try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .collection("comments")
            .document(commentID)
            .collection("threads")
            .addDocument(data: data)
    }

    func deleteReply(visualizationID: String, commentID: String, replyID: String) async throws {
        try await firebase
            .collection("visualizations")
            .document(visualizationID)
            .collection("comments")
            .document(commentID)
            .collection("threads")
            .document(replyID)
            .delete()
    }

    // MARK: - Users

    func fetchUser(userID: String) async throws -> [String: Any]? {
        let doc = try await firebase
            .collection("users")
            .document(userID)
            .getDocument()
        return doc.data()
    }
}
