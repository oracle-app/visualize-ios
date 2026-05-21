//
//  NotificationDTO.swift
//  visualize
//
//  Created by Miguel Degollado on 20/05/26.
//

import Foundation
import FirebaseFirestore

struct NotificationDTO: Codable {
    @DocumentID var id: String?
    let userID: String
    var isRead: Bool
    let type: String
    let createdAt: Date
    let actorName: String
    let actorPhotoURL: String
    let contextLabel: String

    enum CodingKeys: String, CodingKey {
        case id, userID, isRead, type, createdAt, actorName, actorPhotoURL, contextLabel
    }
}
