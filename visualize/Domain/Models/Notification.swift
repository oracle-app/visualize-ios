//
//  Notification.swift
//  visualize
//
//  Created by Miguel Degollado on 15/04/26.
//

import Foundation

struct Notification: Identifiable, Equatable {
    let id: String
    let body: String
    let createdAt: Date
    var isRead: Bool
    let receiverID: String
    let senderProfilePictureURL: String?
    let type: String
}
