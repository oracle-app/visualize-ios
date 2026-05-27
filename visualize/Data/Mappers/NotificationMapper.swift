//
//  NotificationMapper.swift
//  visualize
//
// created By Miguel Degollado

import Foundation

extension NotificationDTO {
    func toDomain() -> Notification {
        Notification(
            id: id ?? UUID().uuidString,
            body: body,
            createdAt: createdAt,
            isRead: isRead,
            receiverID: receiverID,
            senderProfilePictureURL: senderProfilePictureURL.isEmpty ? nil : senderProfilePictureURL,
            type: type
        )
    }
}
