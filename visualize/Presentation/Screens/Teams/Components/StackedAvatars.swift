//
//  StackedAvatars.swift
//  visualize
//
//  Created by Diana Escalante on 20/05/26.
//

import SwiftUI

/// Displays a horizontally stacked group of user avatars with optional overflow count.
/// Reusable across team list components.
struct StackedAvatars: View {

    let members: [AppUser]
    var maxAvatars: Int = 3
    var avatarSize: CGFloat = 30

    private var displayMembers: [AppUser] { Array(members.prefix(maxAvatars)) }
    private var remainingCount: Int { members.count - displayMembers.count }

    var body: some View {
        HStack(spacing: -(avatarSize * 0.3)) {
            ForEach(displayMembers.enumerated(), id: \.element.id) { index, user in
                UserAvatarView(user: user, size: avatarSize, showBorder: true)
                    .zIndex(Double(maxAvatars - index))
            }

            if remainingCount > 0 {
                ZStack {
                    Circle()
                        .fill(Color.appBackground)
                    Text("+\(remainingCount)")
                        .font(.system(size: avatarSize * 0.4, weight: .regular))
                        .foregroundStyle(Color.primaryText)
                }
                .frame(width: avatarSize, height: avatarSize)
                .overlay(Circle().stroke(Color.appMint, lineWidth: 2))
                .zIndex(0)
            }
        }
    }
}
