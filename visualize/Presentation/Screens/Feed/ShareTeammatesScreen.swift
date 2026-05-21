//
//  ShareTeammatesScreen.swift
//  Visualize
//
//  Created by Diana Escalante on 13/04/26.
//

//
/// Main screen that allows users to share content with teammates.
/// It handles UI states (loading, error, loaded), integrates search functionality,
/// and displays both suggested users and selected teammates.
/// Coordinates interactions between the ViewModel and reusable UI components.
//

import SwiftUI

struct ShareTeammatesScreen: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @State private var vm: ShareTeammatesViewModel
    @State private var isSharingExpanded = true
    @State private var isMyTeamsExpanded = true
    @State private var isJoinedTeamsExpanded = true
    /// Called after a successful share confirmation.
    var onConfirm: () -> Void
    /// - Parameters:
    ///   - viewModel: The view model managing search and selection state.
    ///   - onConfirm: Closure executed after the share is persisted successfully.
    init(viewModel: ShareTeammatesViewModel, onConfirm: @escaping () -> Void) {
        _vm = State(initialValue: viewModel)
        self.onConfirm = onConfirm
    }
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 16) {
                VStack(spacing: 5) {
                    Image(systemName: "person.2")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.primaryText)
                    Text("Share to more teammates")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.primaryText)
                }
                contentView
                Spacer()
            }
            .padding(.horizontal, 16)
            if isFocused && vm.email.count >= 3 {
                SearchResultsDropdown(
                    results: vm.suggestedUsers
                ) { user in
                    vm.addUser(user)
                }
                .padding(.top, 140)
                .frame(maxWidth: 360)
                .shadow(radius: 10)
                .zIndex(1000)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.loadTeams() }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm", systemImage: "checkmark") {
                    Task {
                        try? await vm.confirmShare()
                        onConfirm() // Notify before dismissing
                        dismiss()
                    }
                }
                .tint(Color.primaryOrange)
            }
        }
    }
    @ViewBuilder
    private var contentView: some View {
        loadedView()
    }
    private func loadedView() -> some View {
        VStack(spacing: 16) {
            ZStack(alignment: .top) {
                EmailSearchField(
                    email: $vm.email,
                    onClear: { vm.clearEmail() },
                    isFocused: _isFocused
                )
                .frame(maxWidth: 360)
            }

            if vm.isLoading && vm.selectedUsers.isEmpty && vm.myTeams.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                List {
                    // MARK: Sharing with
                    Section {
                        if isSharingExpanded {
                            if vm.selectedUsers.isEmpty {
                                Text("Search for teammates or select a team below.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets())
                            } else {
                                UsersListView(
                                    users: vm.selectedUsers,
                                    onRemove: { vm.removeUser($0) }
                                )
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                            }
                        }
                    } header: {
                        collapsableHeader("Sharing with", isExpanded: $isSharingExpanded)
                    }

                    // MARK: My Teams
                    Section {
                        if isMyTeamsExpanded {
                            if vm.isTeamsLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .listRowBackground(Color.clear)
                            } else if vm.myTeams.isEmpty {
                                Text("You haven't created any teams yet.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets())
                            } else {
                                ForEach(vm.myTeams) { team in
                                    TeamRow(
                                        team: team,
                                        isSelected: vm.isSelected(team),
                                        onTap: { vm.toggleSelection(team) }
                                    )
                                }
                            }
                        }
                    } header: {
                        collapsableHeader("My teams", isExpanded: $isMyTeamsExpanded)
                    }

                    // MARK: Teams I'm in
                    Section {
                        if isJoinedTeamsExpanded {
                            if vm.isTeamsLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .listRowBackground(Color.clear)
                            } else if vm.joinedTeams.isEmpty {
                                Text("You're not part of any teams yet.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets())
                            } else {
                                ForEach(vm.joinedTeams) { team in
                                    TeamRow(
                                        team: team,
                                        isSelected: vm.isSelected(team),
                                        onTap: { vm.toggleSelection(team) }
                                    )
                                }
                            }
                        }
                    } header: {
                        collapsableHeader("Teams I'm in", isExpanded: $isJoinedTeamsExpanded)
                    }
                }
                .listStyle(.insetGrouped)
                .listSectionSpacing(12)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
    }
    
    // MARK: - Collapsable Header
    /// Returns a tappable section header with a chevron that toggles the given expansion binding.
    /// - Parameters:
    ///   - title: The header title to display.
    ///   - isExpanded: Binding that controls the expanded/collapsed state.
    private func collapsableHeader(_ title: String, isExpanded: Binding<Bool>) -> some View {
        Button {
            withAnimation { isExpanded.wrappedValue.toggle() }
        } label: {
            HStack {
                Text(title).foregroundStyle(.black)
                Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.up")
                    .foregroundStyle(.black)
            }
        }
    }
}

// MARK: - Preview
extension ShareTeammatesViewModel {
    static var previewWithUsers: ShareTeammatesViewModel {
        let userDatasource = UserDatasource()
        let teamDatasource = TeamDatasource()
        let authDatasource = AuthFirebaseDatasource()
        let visualizationDatasource = VisualizationDatasource(
            userDatasource: userDatasource,
            teamsDatasource: teamDatasource
        )
        let authRepository = AuthRepositoryImpl(
            source: authDatasource
        )
        return ShareTeammatesViewModel(
            userRepository: UserRepositoryImpl(
                userDatasource: userDatasource
            ),
            teamRepository: TeamRepositoryImpl(
                teamDatasource: teamDatasource,
                userDatasource: userDatasource
            ), authRepository: authRepository,
            updateSharingUseCase: UpdateSharingUseCase(
                visualizationRepository: VisualizationRepositoryImpl(
                    userDatasource: userDatasource,
                    visualizationDatasource: visualizationDatasource,
                    teamsDatasource: teamDatasource
                ),
                userRepository: UserRepositoryImpl(userDatasource: userDatasource)
            ),
            visualizationID: "LnSqGF5VrD73GTjyRZAZ"
        )
    }
}

#Preview {
    NavigationStack {
        ShareTeammatesScreen(
            viewModel: ShareTeammatesViewModel.previewWithUsers,
            onConfirm: {}
        )
    }
}
