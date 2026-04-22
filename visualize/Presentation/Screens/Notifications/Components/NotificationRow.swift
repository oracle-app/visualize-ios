//
//  NotificationRow.swift
//  visualize
//
//  Created by Miguel Degollado  on 22/04/26.



import SwiftUI

struct NotificationRow: View {

    // MARK: - Properties

    let item: Notification
    let showSeparator: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // Unread indicator dot
                Circle()
                    .fill(item.isRead ? Color.clear : Color(red: 0.93, green: 0.28, blue: 0.28))
                    .frame(width: 9, height: 9)
                    .padding(.top, 6)
                    .accessibilityLabel(
                        item.isRead
                            ? ""
                            : NSLocalizedString("notifications.unread.dot.accessibility", comment: "")
                    )

                VStack(alignment: .leading, spacing: 6) {
                    // Notification type displayed as readable label
                    Text(item.type.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.appNavy)
                        .fixedSize(horizontal: false, vertical: true)

                    // Relative timestamp derived from createdAt
                    Text(item.createdAt.relativeFormatted())
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appSubtitle)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if showSeparator {
                Divider()
                    .background(Color(red: 0.90, green: 0.90, blue: 0.90))
                    .padding(.leading, 37)
            }
        }
    }
}

// MARK: - Date helper

private extension Date {
    func relativeFormatted() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - Preview

#Preview("Unread row") {
    NotificationRow(
        item: Notification(
            id: "p1",
            userID: "u1",
            isRead: false,
            type: "thread_reply",
            createdAt: Date().addingTimeInterval(-86_400)
        ),
        showSeparator: true
    )
    .background(Color.appMint)
}

#Preview("Read row – no separator") {
    NotificationRow(
        item: Notification(
            id: "p2",
            userID: "u1",
            isRead: true,
            type: "team_invite",
            createdAt: Date().addingTimeInterval(-86_400)
        ),
        showSeparator: false
    )
    .background(Color.appMint)
}

