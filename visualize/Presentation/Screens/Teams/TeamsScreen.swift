//
//  TeamsScreen.swift
//  visualize
//
//  Created by Diana Escalante on 20/05/26.
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
    @State private var expandedTeamIDs: Set<String> = []

    init(viewModel: TeamsScreenViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            // MARK: - My Teams

            Section {
                if viewModel.myTeams.isEmpty {
                    emptyState("You haven't created any teams yet.")
                        .listRowBackground(Color.clear)
                        .foregroundStyle(Color.secondary)
                } else {
                    ForEach(viewModel.myTeams) { team in
                        TeamSwipeRow(team: team)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    viewModel.deleteTeam(team)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)

                                Button {
                                    viewModel.beginEditing(team)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(Color.appTeal)
                            }
                    }
                }
            } header: {
                sectionHeader("My teams")
            }

            // MARK: - Teams I'm In

            Section {
                if viewModel.joinedTeams.isEmpty {
                    emptyState("You're not part of any teams yet.")
                        .listRowBackground(Color.clear)
                        .foregroundStyle(Color.secondary)
                } else {
                    ForEach(viewModel.joinedTeams) { team in
                        TeamToggleRow(
                            team: team,
                            isExpanded: expandedTeamIDs.contains(team.id)
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if expandedTeamIDs.contains(team.id) {
                                    expandedTeamIDs.remove(team.id)
                                } else {
                                    expandedTeamIDs.insert(team.id)
                                }
                            }
                        }

                        if expandedTeamIDs.contains(team.id) {
                            ForEach(team.members) { member in
                                UserRowView(user: member)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 32, bottom: 4, trailing: 16))
                                    .listRowBackground(Color.appMint.opacity(0.6))
                            }
                        }
                    }
                }
            } header: {
                sectionHeader("Teams I'm in")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Teams")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.beginCreating()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.primaryOrange)
            }
        }
        .task {
            await viewModel.loadTeams()
        }
        .alert("Delete Team", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive, action: viewModel.confirmDelete)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \"\(viewModel.teamPendingDelete?.name ?? "")\"? This action cannot be undone.")
        }
    }

    // MARK: Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(Color.primaryText)
            .textCase(nil)
    }

    private func emptyState(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(Color.appSubtitle)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
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
