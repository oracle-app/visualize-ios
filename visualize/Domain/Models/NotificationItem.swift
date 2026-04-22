
//  NotificationItem.swift
//  visualize
//
//  Created by Miguel Degollado Ramirez on 22/04/26.
//


import Foundation

struct NotificationItem: Identifiable, Equatable {
    let id: UUID
    let message: String
    let timestamp: String
    var isRead: Bool

    init(
        id: UUID = UUID(),
        message: String,
        timestamp: String,
        isRead: Bool = false
    ) {
        self.id = id
        self.message = message
        self.timestamp = timestamp
        self.isRead = isRead
    }
}
