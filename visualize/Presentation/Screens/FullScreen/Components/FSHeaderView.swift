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
    let onBack: () -> Void

    // MARK: - Body

    var body: some View {
        VStack {

            // MARK: Top Row
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.primaryText)
                        .frame(width: 48, height: 48)
                        .glassEffect()
                }

                Spacer()

                if !members.isEmpty {
                    HStack {
                        Text("Shared with:")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.white)
                        TeamAvatarsView(members: members, borderColor: Color.appMint, diameter: 29)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // MARK: Title
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.appTeal.opacity(0.75))
        .background(.ultraThinMaterial.opacity(0.7))
    }
}

// MARK: - Preview

#Preview {
    FSHeaderView(
        title: "Relative performance of major currencies against the dollar",
        members: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana"),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis"),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria"),
            AppUser(id: "4", email: "carlos@mail.com", profilePictureURL: nil, username: "Carlos")
        ],
        onBack: {}
    )
}
