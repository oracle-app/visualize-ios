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
    let content: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, authorID, content, createdAt
    }
}
