//
//  TeamRow.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 11/04/26.
//

import SwiftUI

// MARK: - Team Row

/// Reusable list row that displays a team with its name, member count,
/// member avatars, and a selection indicator.
///
/// This view:
/// - Shows a circular checkbox that reflects the current selection state.
/// - Displays the team name and a member count using grammatical inflection.
/// - Renders up to three member avatars with a "+N" overflow badge.
/// - Fires `onTap` when the user taps anywhere on the row.
struct TeamRowView: View {

    // MARK: - Properties

    let team: Team
    let isSelected: Bool
    let onTap: () -> Void

    // MARK: - Private properties

    private let maxAvatars = 3

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            HStack {
                selectionIndicator
                teamInfo
                Spacer()
                avatarStack
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(AppColors.Brand.mint)
    }

    // MARK: - Selection Indicator

    /// Circular checkbox that fills with a checkmark when the team is selected.
    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? AppColors.Brand.teal : Color.gray.opacity(0.4), lineWidth: 2)
                .frame(width: 24, height: 24)

            if isSelected {
                Circle()
                    .fill(AppColors.Brand.teal)
                    .frame(width: 24, height: 24)
                    .transition(.scale.combined(with: .opacity))

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(isSelected ? .spring(response: 0.3, dampingFraction: 0.6) : .none, value: isSelected)
    }

    // MARK: - Team Info

    /// Displays the team name and a grammatically inflected member count.
    private var teamInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(team.name)
                .font(.body)
                .foregroundStyle(AppColors.Text.primary)

            Text("^[\(team.members.count) member](inflect: true)")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.Brand.teal)
        }
        .padding(.leading, 6)
    }

    // MARK: - Avatar Stack

    /// Renders up to `maxAvatars` member avatars overlapping left-to-right,
    /// followed by a "+N" badge if there are additional members.
    private var avatarStack: some View {
        HStack(spacing: -20) {
            let displayMembers = Array(team.members.prefix(maxAvatars))
            let remainingCount = team.members.count - displayMembers.count

            ForEach(displayMembers.enumerated(), id: \.element.id) { index, user in
                UserAvatarView(user: user, size: 33, showBorder: true)
                    .zIndex(Double(maxAvatars - index))
            }

            if remainingCount > 0 {
                ZStack {
                    Circle().fill(Color.white)
                    Text("+\(remainingCount)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 68/255, green: 68/255, blue: 68/255))
                }
                .frame(width: 33, height: 33)
                .overlay(Circle().stroke(AppColors.Brand.mint, lineWidth: 2))
                .padding(.leading, 10)
            }
        }
    }
}
