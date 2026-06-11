//
//  ThreadReply.swift
//  visualize
//
//  Created by Kimberly Marquez on 5/3/26.
//
import Foundation
import FirebaseFirestore

struct ThreadReply: Identifiable, Codable {
    let id: String?
    var authorID: String
    var authorName: String = ""
    var authorAvatarURL: String?
    var createdAt: Date
    var content: String

    enum CodingKeys: String, CodingKey {
        case id, authorID, authorName, authorAvatarURL, createdAt, content
    }
}
