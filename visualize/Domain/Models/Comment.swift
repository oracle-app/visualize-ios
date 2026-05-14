//
//  Comment.swift
//  visualize
//
//  Created by Kimberly Marquez on 5/3/26.
//
import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var authorID: String
    var authorName: String?
    var content: String?
    var imageURL: String?
    var createdAt: Timestamp
    var threads: [ThreadReply] = []

    enum CodingKeys: String, CodingKey {
        case id, authorID, authorName, content, createdAt, imageURL
    }
}
