//
//  NotificationMapper.swift
//  visualize
//
// created By Miguel Degollado

import SwiftUI

// MARK: - DTO → Domain

extension NotificationDTO {
    func toDomain() -> Notification {
        Notification(
            id: id ?? UUID().uuidString,
            userID: userID,
            isRead: isRead,
            type: type,
            createdAt: createdAt,
            actorName: actorName.isEmpty ? nil : actorName,
            actorPhotoURL: actorPhotoURL.isEmpty ? nil : actorPhotoURL,
            contextLabel: contextLabel.isEmpty ? nil : contextLabel
        )
    }
}

// MARK: - Domain → Display

extension Notification {
    func toDisplayItem() -> NotificationDisplayItem {
        let resolved = type.resolvedMessage(actorName: actorName, context: contextLabel)
        return NotificationDisplayItem(
            id: id,
            boldPrefix: resolved.boldPrefix,
            message: resolved.message,
            timestamp: createdAt.relativeFormatted(),
            isRead: isRead,
            avatarInitials: (actorName ?? "").initials,
            avatarColor: type.avatarColor,
            avatarURL: actorPhotoURL
        )
    }
}

// MARK: - Type resolution

private struct ResolvedMessage { let boldPrefix: String; let message: String }

private extension String {
    func resolvedMessage(actorName: String?, context: String?) -> ResolvedMessage {
        let actor = actorName ?? "Someone"
        let ctx = context ?? ""
        switch self {
        case "thread_reply":
            return ResolvedMessage(boldPrefix: "\(actor) ", message: "replied to your thread on \u{201C}\(ctx)\u{201D}")
        case "team_invite":
            return ResolvedMessage(boldPrefix: "\(actor) ", message: "added you to the team \u{201C}\(ctx)\u{201D}.")
        case "chart_shared":
            return ResolvedMessage(boldPrefix: "\(actor) ", message: "shared a new chart called \u{201C}\(ctx)\u{201D}.")
        default:
            return ResolvedMessage(boldPrefix: "", message: "You have a new notification.")
        }
    }

    var avatarColor: Color {
        switch self {
        case "thread_reply": return Color(red: 0.40, green: 0.62, blue: 0.95)
        case "team_invite":  return Color(red: 0.95, green: 0.58, blue: 0.40)
        case "chart_shared": return Color(red: 0.40, green: 0.80, blue: 0.65)
        default:             return Color(red: 0.80, green: 0.45, blue: 0.75)
        }
    }

    var initials: String {
        split(separator: " ").prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined().uppercased()
    }
}
