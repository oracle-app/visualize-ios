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
    let timestamp: String
    let isRead: Bool
    let avatarInitials: String
    let avatarColor: Color
    var avatarURL: String? = nil
}

extension Date {
    func relativeFormatted() -> String {
        let seconds = Date().timeIntervalSince(self)
        if seconds < 60 { return String(localized: "now") }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
