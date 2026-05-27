//
//  ShareSheet.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 11/04/26.
//

import SwiftUI

// MARK: - Share Mode

/// Represents the two sharing options available to the user.
private enum ShareMode {
    case personal
    case teammates
}

// MARK: - Share Sheet View

/// Bottom sheet that presents sharing options for a generated visualization.
///
/// This view handles two states:
/// - An initial picker with "Save in personal feed" and "Share with teammates" options.
/// - A full teammates view with user search, selected users, and team selection lists.
///
/// The sheet size is controlled externally via `sheetSize` so the parent
/// (`VizReadyView`) can expand or collapse it programmatically.
struct ShareSheet: View {

    // MARK: - State

    @State private var vm: ShareSheetViewModel
    @State private var selectedOption: ShareMode? = nil
    @State private var isConfirming: Bool = false

    @Binding var sheetSize: PresentationDetent

    @State private var isSharingExpanded = true
    @State private var isMyTeamsExpanded = true
    @State private var isJoinedTeamsExpanded = true

    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    /// Called after the visualization is successfully created in Firestore.
    var onConfirm: (() -> Void)?

    // MARK: - Init

    init(viewModel: ShareSheetViewModel, sheetSize: Binding<PresentationDetent>, onConfirm: (() -> Void)? = nil) {
        _vm = State(initialValue: viewModel)
        _sheetSize = sheetSize
        self.onConfirm = onConfirm
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack {
                if selectedOption == nil || selectedOption == .personal {
                    initialView
                        .transition(.opacity)
                        .id("initial")
                }

                if selectedOption == .teammates {
                    teammatesView
                        .transition(.opacity)
                        .id("teammates")
                }
 
                // Show Firestore error inline so the user knows the save failed
                if let error = vm.confirmError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.22), value: selectedOption)
            .toolbar { toolbar }
        }
        .onDisappear {
            sheetSize = .fraction(0.28)
            selectedOption = nil
        }
    }

    // MARK: - Initial View

    /// Compact picker shown when the sheet first appears.
    /// Lets the user choose between saving to their personal feed or sharing with teammates.
    private var initialView: some View {
        VStack(spacing: 16) {
            Button {
                selectedOption = .personal
            } label: {
                Text("Save in personal feed")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(selectedOption == .personal ? .white : Color.appTeal)
                    .frame(maxWidth: 360)
                    .frame(height: 45)
                    .background(Color.appTeal.opacity(selectedOption == .personal ? 1 : 0))
                    .background(.white)
                    .clipShape(.capsule)
                    .overlay(Capsule().stroke(Color.appTeal, lineWidth: 1.5))
                    .overlay(
                        Capsule()
                            .stroke(Color.white, lineWidth: selectedOption == .personal ? 2 : 0)
                    )
            }

            if selectedOption == .personal {
                Text(String(localized: "You can share this with teammates later."))                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .transition(.opacity)
            }

            Button {
                selectedOption = nil
                selectedOption = .teammates
                sheetSize = .large
                vm.loadData()
            } label: {
                Text("Share with teammates")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.appTeal)
                    .frame(maxWidth: 360)
                    .frame(height: 45)
                    .background(.white)
                    .clipShape(.capsule)
                    .overlay(Capsule().stroke(Color.appTeal, lineWidth: 1.5))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: selectedOption)
    }

    // MARK: - Teammates View

    /// Expanded view showing user search, selected users, and team selection lists.
    private var teammatesView: some View {
        VStack(spacing: 16) {
            Text("Share with teammates")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.primaryText)

            EmailSearchField(
                email: $vm.email,
                onClear: vm.clearEmail,
                isFocused: _isFocused
            )
            .frame(maxWidth: 360)

            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section {
                        if isSharingExpanded {
                            if vm.selectedUsers.isEmpty {
                                Text(String(localized: "Select teammates individually, or choose a team below."))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets())
                            } else {
                                UsersListView(
                                    users: vm.selectedUsers,
                                    onRemove: vm.removeUser
                                )
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                            }
                        }
                    } header: {
                        collapsableHeader(String(localized: "Sharing with"), isExpanded: $isSharingExpanded)
                    }

                    Section {
                        if isMyTeamsExpanded {
                            if vm.myTeams.isEmpty {
                                Text(String(localized: "You don't own any teams yet."))
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
                        collapsableHeader(String(localized: "My teams"), isExpanded: $isMyTeamsExpanded)
                    }

                    Section {
                        if isJoinedTeamsExpanded {
                            if vm.joinedTeams.isEmpty {
                                Text(String(localized: "You haven't joined any teams yet."))
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
                        collapsableHeader(String(localized: "Teams I'm in"), isExpanded: $isJoinedTeamsExpanded)
                    }
                }
                .listStyle(.insetGrouped)
                .listSectionSpacing(12)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .overlay(alignment: .top) {
            if isFocused && !vm.suggestedUsers.isEmpty {
                SearchResultsDropdown(
                    results: vm.suggestedUsers,
                    onSelect: vm.addUser
                )
                .frame(maxWidth: 360)
                .padding(.top, 100)
            }
        }
    }

    // MARK: - Toolbar

    /// Navigation bar buttons: cancel (xmark) and confirm (paperplane).
    private var toolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    sheetSize = .fraction(0.28)
                    selectedOption = nil
                    dismiss()
                }
                .tint(Color.appNavy)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm", systemImage: "paperplane.fill") {
                    Task {
                        isConfirming = true
                        defer { isConfirming = false }
                        do {
                            try await vm.confirmShare()
                            // Only dismiss and notify parent on success
                            dismiss()
                            onConfirm?()
                        } catch {
                            // Error is surfaced via vm.confirmError, sheet stays open
                            vm.confirmError = error.localizedDescription
                        }
                    }
                }
                .tint(Color.primaryOrange)
                .disabled(selectedOption == nil || isConfirming)
            }
        }
    }

    // MARK: - Collapsable Header

    /// Returns a tappable header row with a chevron that toggles the given expansion binding.
    private func collapsableHeader(_ title: String, isExpanded: Binding<Bool>) -> some View {
        Button {
            withAnimation {
                isExpanded.wrappedValue.toggle()
            }
        } label: {
            HStack {
                Text(title).foregroundStyle(Color.primaryText)

                Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.up")
                    .foregroundStyle(Color.primaryText)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let userDatasource = UserDatasource()
    let teamDatasource = TeamDatasource()
    let authDatasource = AuthFirebaseDatasource()
    let vizDatasource = VisualizationDatasource(
        userDatasource: userDatasource,
        teamsDatasource: teamDatasource
    )
    let authRepository = AuthRepositoryImpl(source: authDatasource)
    NavigationStack {
        ShareSheet(
            viewModel: ShareSheetViewModel(
                teamRepository: TeamRepositoryImpl(
                    teamDatasource: teamDatasource,
                    userDatasource: userDatasource
                ),
                userRepository: UserRepositoryImpl(userDatasource: userDatasource),
                authRepository: authRepository,
                createVisualizationUseCase: CreateVisualizationUseCase(
                    visualizationRepository: VisualizationRepositoryImpl(
                        userDatasource: userDatasource,
                        visualizationDatasource: vizDatasource,
                        teamsDatasource: teamDatasource
                    )
                ),
                chartTitle: "Survival Rate by Passenger Class",
                chartConfigJSON: MockChartJSONs.verticalBarConfig,
                chartPreviewJSON: MockChartJSONs.verticalBarPreview
            ),
            sheetSize: .constant(.large)
        )
    }
}
