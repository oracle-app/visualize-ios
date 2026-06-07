//
//  NotificationRow.swift
//  visualize
//

import SwiftUI

struct NotificationRowView: View {
    let item: NotificationDisplayItem
    let showSeparator: Bool
    var onTap: ((String) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                NotificationAvatarView(
                    initials: item.avatarInitials,
                    size: 40,
                    avatarURL: item.avatarURL
                )
                .padding(.top, 2)
                .overlay(alignment: .leading) {
                    if !item.isRead {
                        Circle()
                            .fill(Color.appRed)
                            .frame(width: 8, height: 8)
                            .offset(x: -28)
                    }
                }
                HStack(alignment: .top, spacing: 8) {
                    Text("\(Text(item.boldPrefix).font(.system(size: 16, weight: .semibold)))\(Text(item.message).font(.system(size: 16)))")
                        .foregroundStyle(Color.appNavy)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.timestamp.relativeFormatted())
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appSubtitle)
                        .fixedSize()
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
