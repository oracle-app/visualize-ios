//
//  TeamsToggleList.swift
//  visualize
//
//  Created by Diana Escalante on 20/05/26.
//

//
/// A scrollable list of teams the current user belongs to (but did not create).
/// Tapping a row expands it to show all members vertically using UserRowView.
/// Collapsed state shows team name, member count, and stacked avatars.
//

import SwiftUI

struct TeamToggleRow: View {

    let team: Team
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.body.bold())
                        .foregroundStyle(Color.primaryText)

                    Text("\(team.memberCount) member\(team.memberCount == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTeal)
                }

                Spacer()
                
                if !isExpanded {
                    StackedAvatars(members: team.members, maxAvatars: 3)
                }

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSubtitle)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.appMint)
    }
}

