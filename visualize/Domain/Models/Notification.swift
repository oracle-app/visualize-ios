//
//  Notification.swift
//  visualize
//
//  Created by Miguel Degollado on 15/04/26.
//

import Foundation

struct Notification: Identifiable, Equatable {
    let id: String
    let userID: String
    var isRead: Bool
    let type: String
    let createdAt: Date
    let actorName: String?
    let actorPhotoURL: String?
    let contextLabel: String?
}
