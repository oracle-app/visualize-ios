//
//  NotificationDisplayItem.swift
//  visualize
//
//  Created by Miguel Degollado 
//
import SwiftUI

struct NotificationDisplayItem: Identifiable, Equatable {
    let id: String
    let boldPrefix: String
    let message: String
    let timestamp: Date
    let isRead: Bool
    let avatarInitials: String
    let avatarColor: Color
    var avatarURL: String? = nil
}


