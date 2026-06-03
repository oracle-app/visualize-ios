//
//  TeamsSwipeList.swift
//  visualize
//
//  Created by Diana Escalante on 20/05/26.
//

import SwiftUI

/// A scrollable list of teams owned by the current user.
/// Each row shows the team name, member count, and a stacked avatar group.
/// Supports swipe-left actions to delete or edit a team.
struct TeamsSwipeListView: View {

    let teams: [Team]
    let onDelete: (Team) -> Void
    let onEdit: (Team) -> Void

    var body: some View {
        List {
            ForEach(teams) { team in
                TeamSwipeRow(team: team)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparatorTint(AppColors.UI.gray)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            onDelete(team)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            onEdit(team)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(AppColors.Brand.teal)
                    }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - TeamSwipeRow

/// A single row in the swipe list showing team info and stacked member avatars.
struct TeamSwipeRow: View {

    let team: Team

    private let maxAvatars = 3

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.body.bold())
                    .foregroundStyle(AppColors.Text.primary)

                Text("\(team.memberCount) member\(team.memberCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.Brand.teal)
            }

            Spacer()
            
            StackedAvatarsView(members: team.members, maxAvatars: maxAvatars)
        }
        .padding(.vertical, 4)
        .listRowBackground(AppColors.Brand.mint)
    }
}

// MARK: - Preview

#Preview {
    TeamsSwipeListView(
        teams: [
            Team(id: "1", name: "Design Team", ownerID: "1", memberCount: 3, members: []),
            Team(id: "2", name: "Backend Crew", ownerID: "1", memberCount: 5, members: [])
        ],
        onDelete: { _ in },
        onEdit: { _ in }
    )
}
