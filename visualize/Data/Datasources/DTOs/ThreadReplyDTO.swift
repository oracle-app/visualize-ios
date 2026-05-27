//
//  ThreadReplyDTO.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation
import FirebaseFirestore

struct ThreadReplyDTO: Codable {
    @DocumentID var id: String?
    let authorID: String
    let authorName: String?
    let authorAvatarURL: String?
    let content: String
    let createdAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case id, authorID, authorName, authorAvatarURL, content, createdAt
    }
}
