//
//  NotificationGroupCard.swift
//  visualize
//
//  Created by Miguel Degollado Ramirez on 22/04/26.

import SwiftUI

struct NotificationGroupCard: View {

    // MARK: - Properties

    let group: NotificationsGroup

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(group.notifications.enumerated()), id: \.element.id) { index, item in
                NotificationRow(
                    item: item,
                    showSeparator: index < group.notifications.count - 1
                )
            }
        }
        .background(Color.appMint)
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }
}

// MARK: - Preview

#Preview {
    NotificationGroupCard(
        group: NotificationsGroup(
            id: "Yesterday",
            notifications: [
                Notification(id: "p1", userID: "u1", isRead: false, type: "thread_reply", createdAt: Date().addingTimeInterval(-86_400)),
                Notification(id: "p2", userID: "u1", isRead: true,  type: "team_invite",  createdAt: Date().addingTimeInterval(-86_400))
            ]
        )
    )
    .padding()
    .background(Color.appBackground)
}
