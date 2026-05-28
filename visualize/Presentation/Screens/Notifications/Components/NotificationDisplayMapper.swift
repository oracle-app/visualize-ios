//
//  NotificationDisplayMapper.swift
//  visualize
//
//  Created by Carlos Amador on 27/05/26.
//

import SwiftUI

extension Notification {
    func toDisplayItem() -> NotificationDisplayItem {

        let senderName = body.extractSenderName()

        return NotificationDisplayItem(
            id: id,
            boldPrefix: senderName.isEmpty ? "" : "\(senderName) ",
            message: senderName.isEmpty ? body : String(body.dropFirst(senderName.count + 1)),
            timestamp: createdAt.relativeFormatted(),
            isRead: isRead,
            avatarInitials: senderName.initials,
            avatarColor: type.avatarColor,
            avatarURL: senderProfilePictureURL
        )
    }
}

// MARK: - Helpers

private extension String {

    /// Extracts the sender name from the body string.
    func extractSenderName() -> String {
        let verbs = [" shared ", " replied ", " added ", " commented "]
        for verb in verbs {
            if let range = range(of: verb) {
                return String(self[startIndex..<range.lowerBound])
            }
        }
        return ""
    }

    var avatarColor: Color {
        switch self {
        case "visualization_shared": return Color(red: 0.40, green: 0.62, blue: 0.95)
        case "thread_reply":         return Color(red: 0.95, green: 0.58, blue: 0.40)
        case "team_invite":          return Color(red: 0.40, green: 0.80, blue: 0.65)
        default:                     return Color(red: 0.80, green: 0.45, blue: 0.75)
        }
    }

    var initials: String {
        split(separator: " ").prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined().uppercased()
    }
}
