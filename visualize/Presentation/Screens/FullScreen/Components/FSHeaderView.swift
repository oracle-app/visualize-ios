//
//  FSHeaderView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 28/04/26.
//
/// Header component for the Full Screen visualization view.
/// Displays a back button, the visualization title, and the list
/// of users the visualization has been shared with.
import SwiftUI

struct FSHeaderView: View {

    // MARK: - Properties

    let title: String
    let members: [AppUser]
    let isCompact: Bool
    let onBack: () -> Void

    // MARK: - Private

    private var sharedWithText: String {
        switch members.count {
        case 0: return ""
        case 1: return String(localized: "Shared with 1 member")
        default: return String(localized: "Shared with \(members.count) members")
        }
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Button(action: onBack) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 22))
                    .foregroundStyle(AppColors.Text.primary)
                    .frame(width: 48, height: 48)
                    .glassEffect()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: isCompact ? 18 : 22, weight: .bold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                if !members.isEmpty {
                    Text(sharedWithText)
                        .font(.system(size: isCompact ? 12 : 16))
                        .foregroundStyle(Color.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, isCompact ? 8 : 16)
        .background(AppColors.Brand.teal.opacity(0.75))
        .background(.ultraThinMaterial.opacity(0.7))
    }
}

// MARK: - Preview

#Preview("Portrait") {
    FSHeaderView(
        title: "Relative performance of major currencies against the dollar",
        members: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana", role: .admin),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis", role: .admin),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria", role: .admin),
            AppUser(id: "4", email: "carlos@mail.com", profilePictureURL: nil, username: "Carlos", role: .admin)
        ],
        isCompact: false,
        onBack: {}
    )
}

#Preview("Landscape") {
    FSHeaderView(
        title: "Relative performance of major currencies against the dollar",
        members: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana", role: .admin),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis", role: .admin)
        ],
        isCompact: true,
        onBack: {}
    )
}
