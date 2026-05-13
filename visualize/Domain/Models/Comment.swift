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
    var content: String
    var createdAt: Timestamp
    var imageURL: String?
    
    var threads: [ThreadReply] = []
    
    enum CodingKeys: String, CodingKey {
        case id, authorID, content, createdAt, imageURL
    }
    
}

