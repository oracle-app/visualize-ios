//
//  NotificationDTO.swift
//  visualize
//

import Foundation
import FirebaseFirestore

struct NotificationDTO: Codable {
    @DocumentID var id: String?
    let body: String
    let createdAt: Date
    var isRead: Bool
    let receiverID: String
    let senderProfilePictureURL: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case id
        case body
        case createdAt
        case isRead
        case receiverID
        case senderProfilePictureURL
        case type
    }
}
