//
//  FSTeamAvatarView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 28/04/26.
//
/// Displays a compact overlapping row of member avatars.
/// Shows up to 3 profile pictures (or initials as fallback),
/// with a overflow counter badge for additional members.

import SwiftUI

struct TeamAvatarsView: View {

    // MARK: - Properties

    let members: [AppUser]
    let borderColor: Color
    let diameter: CGFloat

    // MARK: - Body

    var body: some View {
        HStack(spacing: -15) {
            ForEach(Array(members.prefix(3).enumerated()), id: \.offset) { index, member in
                avatarView(for: member)
                    .zIndex(Double(3 - index))
            }

            // MARK: Overflow Badge
            if members.count > 3 {
                ZStack {
                    Circle().fill(.white)
                    Text("+\(members.count - 3)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.primaryText)
                }
                .frame(width: diameter, height: diameter)
                .overlay(Circle().stroke(borderColor, lineWidth: 2))
                .padding(.leading, 8)
                .zIndex(0)
            }
        }
    }

    // MARK: - Avatar View

    /// Renders a profile picture from URL or falls back to initials.
    @ViewBuilder
    private func avatarView(for member: AppUser) -> some View {
        Group {
            if let urlString = member.profilePictureURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    initialsView(for: member)
                }
            } else {
                initialsView(for: member)
            }
        }
        .frame(width: diameter, height: diameter)
        .clipShape(Circle())
        .overlay(Circle().stroke(borderColor, lineWidth: 2))
    }

    // MARK: - Initials View

    /// Renders a colored circle with the first letter of the username.
    private func initialsView(for member: AppUser) -> some View {
        ZStack {
            Circle().fill(Color.appTeal)
            Text(member.username.prefix(1).uppercased())
                .font(.system(size: diameter * 0.4, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Preview

#Preview {
    TeamAvatarsView(
        members: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana"),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis"),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria"),
            AppUser(id: "4", email: "carlos@mail.com", profilePictureURL: nil, username: "Carlos")
        ],
        borderColor: Color.appMint,
        diameter: 29
    )
    .padding()
    .background(Color.appTeal)
}
