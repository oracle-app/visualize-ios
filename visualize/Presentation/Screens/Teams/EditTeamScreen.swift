//
//  EditTeamScreen.swift
//  visualize
//
//  Created by Diana Escalante on 26/05/26.
//

import SwiftUI

/// Sheet that lets the team owner edit a team's members.
/// Supports searching users by email to add new members and removing existing ones.
/// On confirmation, persists the updated members list to the team.
struct EditTeamScreen: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @State private var viewModel: EditTeamScreenViewModel

    /// Called after the members list is persisted successfully.
    var onConfirm: () -> Void

    /// - Parameters:
    ///   - viewModel: The view model managing search and member state.
    ///   - onConfirm: Closure executed after the changes are persisted successfully.
    init(viewModel: EditTeamScreenViewModel, onConfirm: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onConfirm = onConfirm
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 16) {
                VStack(spacing: 5) {
                    Image(systemName: "person.2")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppColors.Text.primary)
                    Text("Edit your team")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppColors.Text.primary)
                }
                loadedView()
                Spacer()
            }
            .padding(.horizontal, 16)

            if isFocused && viewModel.email.count >= 3 {
                SearchResultsDropdown(
                    results: viewModel.suggestedUsers
                ) { user in
                    viewModel.addUser(user)
                }
                .padding(.top, 140)
                .frame(maxWidth: 360)
                .shadow(radius: 10)
                .zIndex(1000)
                .transition(.opacity.combined(with: .move(edge: .top)))
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm", systemImage: "checkmark") {
                    Task {
                        do {
                            try await viewModel.confirmChanges()
                            onConfirm()
                            dismiss()
                        } catch {
                            // The error toast was already shown by the ViewModel; the sheet remains open.
                        }
                    }
                }
                .tint(AppColors.Brand.primaryOrange)
            }
        }
        .portraitOrientationLock()
    }

    private func loadedView() -> some View {
        VStack(spacing: 16) {
            ZStack(alignment: .top) {
                EmailSearchFieldView(
                    email: $viewModel.email,
                    onClear: { viewModel.clearEmail() },
                    isFocused: _isFocused
                )
                .frame(maxWidth: 360)
            }

            List {
                Section {
                    if viewModel.members.isEmpty {
                        Text("Search for teammates to add members.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                    } else {
                        VStack(spacing: 0) {
                            if let owner = viewModel.owner {
                                OwnerRowView(user: owner)

                                if !viewModel.nonOwnerMembers.isEmpty {
                                    Divider()
                                }
                            }

                            UsersListView(
                                users: viewModel.nonOwnerMembers,
                                onRemove: { viewModel.removeUser($0) }
                            )
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    Text("Members")
                        .foregroundStyle(AppColors.Text.primary)
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(12)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }
}

// MARK: - Preview

/// Mock user repository used only for previews, returning sample email suggestions.
private final class PreviewUserRepository: UserRepository {

    private let sampleUsers: [AppUser] = [
        AppUser(id: "u5", email: "sofia@example.com", profilePictureURL: nil, username: "Sofía Torres", role: .writer),
        AppUser(id: "u6", email: "diego@example.com", profilePictureURL: nil, username: "Diego Mora", role: .writer)
    ]

    func getUserByID(userID: String) async throws -> AppUser {
        sampleUsers[0]
    }

    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] {
        sampleUsers
    }

    func createUser(user: AppUser) async throws -> AppUser { user }

    func addHiddenVisualization(userID: String, visualizationID: String) async throws {}

    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {}
    
    func updateProfilePictureURL(userID: String, url: URL?) async throws {}

    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL {
        URL(string: "https://example.com/profile.jpg")!
    }

    func deleteProfileImage(userID: String) async throws {}
}

#Preview {
    let members = [
        AppUser(id: "u1", email: "ana@example.com", profilePictureURL: nil, username: "Ana García", role: .writer),
        AppUser(id: "u2", email: "luis@example.com", profilePictureURL: nil, username: "Luis Pérez", role: .writer),
        AppUser(id: "u3", email: "maria@example.com", profilePictureURL: nil, username: "María López", role: .writer)
    ]

    NavigationStack {
        EditTeamScreen(
            viewModel: EditTeamScreenViewModel(
                teamRepository: MockTeamRepository(),
                userRepository: PreviewUserRepository(),
                teamID: "t1",
                ownerID: "u1",
                initialMembers: members
            ),
            onConfirm: {}
        )
    }
}
