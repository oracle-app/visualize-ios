//
//  OwnerRow.swift
//  visualize
//
//  Created by Diana Escalante on 26/05/26.
//

import SwiftUI

/// A row component that displays the team owner's information (avatar, name and email)
/// along with an "owner" label on the trailing edge.
///
/// Unlike `UserRowView`, this row is not removable and is meant to identify the owner
/// at the top of a member list.
struct OwnerRowView: View {

    let user: AppUser

    var body: some View {
        HStack(spacing: 12) {

            UserAvatarView(
                user: user,
                size: 40,
                showBorder: false
            )

            VStack(alignment: .leading, spacing: 2) {

                Text(user.username)
                    .font(.body.weight(.bold))
                    .foregroundStyle(AppColors.Text.primary)

                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.Text.primary)
                    .opacity(0.5)
            }

            Spacer()

            Text("owner")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.Text.secondary)
                .fontWeight(.semibold)
        }
        .padding(8)
    }
}
