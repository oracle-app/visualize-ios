//
//  NotificationGroupCard.swift
//  visualize
//

import SwiftUI

struct NotificationGroupCard: View {
    let group: NotificationDisplayGroup
    var onTap: ((String) -> Void)? = nil

    private var hasUnread: Bool {
        group.items.contains { !$0.isRead }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                ForEach(Array(group.items.enumerated()), id: \.element.id) { index, item in
                    NotificationRow(
                        item: item,
                        showSeparator: index < group.items.count - 1,
                        onTap: onTap
                    )
                }
            }
            .background(Color.appMint)
            .clipShape(RoundedRectangle(cornerRadius: 26))
            if hasUnread {
                Circle()
                    .fill(Color.appRed)
                    .frame(width: 8, height: 8)
                    .offset(x: -16)
            }
        }
    }
}
