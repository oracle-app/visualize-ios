//
//  FullScreenView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 24/04/26.
//

import SwiftUI

struct FullScreenView: View {
    let card: VisualizationCard
    /// Declaration of view model
    @State private var viewModel: FullScreenViewModel
    @Environment(\.dismiss) private var dismiss
    init(card: VisualizationCard) {
            self.card = card
            self._viewModel = State(initialValue: FullScreenViewModel(
                teamRepository: TeamRepositoryImpl(
                    teamDatasource: TeamDatasource(),
                    userDatasource: UserDatasource()
                )
            ))
        }
    var body: some View {
        ZStack {
            Color.appMint
                .ignoresSafeArea()
           ///  Component for charts with zoom functionality
            FSChartView(imageName: "MockChart")
                .frame(height: 110)
            VStack {
                /// Component for header
                FSHeaderView(
                    title: card.title,
                    members: card.allUsersSharedWith,
                    onBack: { dismiss() }
                )
                HStack {
                    Spacer()
                        .frame(height: 70)
                    Button {
                        // functionality
                    } label: {
                        Image(systemName: "crop")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .glassEffect(.regular.tint(Color.primaryOrange), in: Circle())
                    }
                    .padding(.trailing)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .preventScreenShot()
    }
}

#Preview {
    FullScreenView(card: VisualizationCard(
        id: "preview-id",
        title: "Relative performance of major currencies against the dollar",
        author: "Mariana Islas",
        createdAt: Date(),
        configJSON: "{}",
        teamsSharedWith: [],
        usersSharedWith: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana"),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis"),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria")
        ],
        allUsersSharedWith: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana"),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis"),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria")
        ]
    ))
}
