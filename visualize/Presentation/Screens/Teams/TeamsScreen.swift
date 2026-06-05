//
//  TeamsScreen.swift
//  visualize
//
//  Created by Diana Escalante on 20/05/26.
//

import SwiftUI

/// The main screen for managing and browsing teams.
/// Divided into two sections:
///   - "My Teams": teams created by the user, with swipe to delete or edit.
///   - "Teams I'm In": teams the user belongs to, with tap-to-expand member list.
struct TeamsScreen: View {
    
    @Environment(AppCoordinator.self) private var coordinator

    @State private var viewModel: TeamsScreenViewModel
    @State private var expandedTeamIDs: Set<String> = []

    init(viewModel: TeamsScreenViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            // MARK: - My Teams
            
            if (viewModel.currentUserRole != .consumer) {
                Section {
                    if viewModel.isLoading && !viewModel.hasLoadedOnce {
                            loadingState
                    } else if viewModel.myTeams.isEmpty {
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
            }

            // MARK: - Teams I'm In

            Section {
                if viewModel.isLoading && !viewModel.hasLoadedOnce {
                        loadingState
                } else if viewModel.joinedTeams.isEmpty {
                    emptyState("You're not part of any teams yet.")
                        .listRowBackground(Color.clear)
                        .foregroundStyle(Color.secondary)
                } else {
                    ForEach(viewModel.joinedTeams) { team in
                        
                        if viewModel.currentUserRole == .admin {
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
                            
                        } else {
                            TeamToggleRowView(
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
                                    Group {
                                        if member.id == team.ownerID {
                                            OwnerRowView(user: member)
                                        } else {
                                            UserRowView(user: member)
                                        }
                                    }
                                    .listRowInsets(EdgeInsets(top: 4, leading: 32, bottom: 4, trailing: 16))
                                    .listRowBackground(Color.appMint.opacity(0.6))
                                }
                            }
                        }
                    }
                }
            } header: {
                sectionHeader("Teams I'm in")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .navigationTitle("Teams")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if viewModel.currentUserRole != .consumer {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        coordinator.pushTeams(.createTeam)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.primaryOrange)
                }
            }
        }
        .task {
            await viewModel.loadTeams()
        }
        .refreshable {
            await viewModel.loadTeams()
        }
        .alert("Delete Team", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive, action: viewModel.confirmDelete)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \"\(viewModel.teamPendingDelete?.name ?? "")\"? This action cannot be undone.")
        }
        .sheet(item: $viewModel.teamToEdit) { team in
            NavigationStack {
                EditTeamScreen(
                    viewModel: viewModel.makeEditViewModel(for: team),
                    onConfirm: { viewModel.didFinishEditing(teamName: team.name) }
                )
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = viewModel.currentToast {
                ToastView(toast: toast)
                    .padding(.bottom, 24)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity.combined(with: .scale(scale: 0.95))
                        )
                    )
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: viewModel.currentToast)
        .appBackground()
    }

    // MARK: Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(Color.primaryText)
            .textCase(nil)
    }
    
    private var loadingState: some View {
        ProgressView()
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
    }

    /// Generates a standardized view to display when a list section is empty.
    ///
    /// - Parameter message: The text content explaining the empty state.
    /// - Returns: A descriptive text view styled for empty lists.
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
                authRepository: MockAuthRepository(),
                userRepository: UserRepositoryImpl(userDatasource: UserDatasource())
            )
        )
        .environment(AppCoordinator())
    }
}
