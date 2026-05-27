//
//  NotificationRow.swift
//  visualize
//
//  Created by Miguel Degollado

import SwiftUI

struct NotificationRow: View {
    let item: NotificationDisplayItem
    let showSeparator: Bool
    var onTap: ((String) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                NotificationAvatarView(
                    initials: item.avatarInitials,
                    color: item.avatarColor,
                    size: 40,
                    avatarURL: item.avatarURL
                )
                .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.timestamp)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appSubtitle)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Text("\(Text(item.boldPrefix).font(.system(size: 16, weight: .semibold)))\(Text(item.message).font(.system(size: 16)))")
                        .foregroundStyle(Color.appNavy)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)

            if showSeparator {
                Divider()
                    .background(Color.appNavy.opacity(0.1))
                    .padding(.leading, 68)
                    .padding(.trailing, 16)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !item.isRead else { return }
            onTap?(item.id)
        }
    }
}
