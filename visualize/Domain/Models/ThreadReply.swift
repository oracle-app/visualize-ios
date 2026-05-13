//
//  ThreadReply.swift
//  visualize
//
//  Created by user291280 on 5/3/26.
//
import Foundation
import FirebaseFirestore
struct ThreadReply: Identifiable, Codable {
    @DocumentID var id: String?
    
    var authorID: String
    var authorName: String = " "
    var authorAvatarURL: String?
    var createdAt: Timestamp
    var content: String
    var timeAgo: String = ""
}
