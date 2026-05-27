//
//  CommentDTO.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation
import FirebaseFirestore

struct CommentDTO: Codable {
    @DocumentID var id: String?
    let authorID: String
    let authorName: String?
    let authorAvatarURL: String? 
    let content: String?
    let imageURL: String?
    let createdAt: Timestamp
}
