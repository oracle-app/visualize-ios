//
//  TeamsScreen.swift
//  visualize
//
//  Created by Diana Escalante on 25/05/26.
//

//
/// The main screen for managing and browsing teams.
/// Divided into two sections:
///   - "My Teams": teams created by the user, with swipe to delete or edit.
///   - "Teams I'm In": teams the user belongs to, with tap-to-expand member list.
//

import SwiftUI

struct TeamsScreen: View {

    @State private var viewModel: TeamsScreenViewModel

    init(viewModel: TeamsScreenViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Teams")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TeamsScreen(
            viewModel: TeamsScreenViewModel(
                teamRepository: MockTeamRepository(),
                authRepository: MockAuthRepository()
            )
        )
        .environment(AppCoordinator())
    }
}
