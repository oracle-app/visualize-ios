//
//  CreateTeamScreen.swift
//  visualize
//
//  Created by Libia Fv on 18/05/26.
//

import SwiftUI

/// Screen responsible for creating a new team.
///
/// This view allows the user to:
/// - Enter a team name
/// - Search users by email
/// - Add or remove teammates
/// - View suggested users
/// - Confirm team creation
///
/// The screen also handles:
/// - Inline validation states
/// - Search dropdown interactions
/// - Success/error toast feedback
/// - Navigation through `AppCoordinator`
struct CreateTeamScreen: View {
    
    // MARK: - Environment
    
    /// Global navigation coordinator.
    @Environment(AppCoordinator.self) private var coordinator
    
    // MARK: - Focus State
    
    /// Controls the focus state of the email search field.
    @FocusState private var isSearchFocused: Bool
    
    /// Controls the focus state of the team name field.
    @FocusState private var isTeamNameFocused: Bool
    
    // MARK: - State
    
    /// ViewModel containing all business logic and UI state.
    @State private var vm: CreateTeamViewModel
    
    // MARK: - Callbacks
    
    /// Callback executed after a successful team creation.
    var onConfirm: () -> Void

    // MARK: - Initializer
    
    init(viewModel: CreateTeamViewModel, onConfirm: @escaping () -> Void) {
        _vm = State(initialValue: viewModel)
        self.onConfirm = onConfirm
    }

    // MARK: - Computed Properties
    
    /// Team owner (first member in the array).
    private var owner: AppUser? { vm.members.first }
    
    /// All members excluding the owner.
    private var nonOwnerMembers: [AppUser] { Array(vm.members.dropFirst()) }

    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: - Background
            
            Color.appBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: - Title
                    
                    Text("Create new team")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 16)

                    // MARK: - Team Name Input
                    
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(
                            "",
                            text: $vm.teamName,
                            prompt: Text("Team's name")
                                .foregroundStyle(
                                    vm.teamNameError != nil
                                    ? AppColors.Status.red
                                    : AppColors.Text.primary.opacity(0.5)
                                )
                        )
                        .focused($isTeamNameFocused)
                        .foregroundStyle(AppColors.Text.authFieldText)
                        .tint(vm.teamNameError != nil ? AppColors.Status.red : AppColors.Brand.teal)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            vm.teamNameError != nil
                            ? AppColors.UI.authErrorBackground
                            : AppColors.UI.background
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    vm.teamNameError != nil
                                    ? AppColors.Status.red
                                    : ( isTeamNameFocused
                                        ? AppColors.Brand.teal.opacity(0.7)
                                        : AppColors.Brand.teal.opacity(0.15)
                                    ),
                                    lineWidth: isTeamNameFocused || vm.teamNameError != nil ? 1.8 : 1
                                )
                                .animation(.easeInOut(duration: 0.2), value: isTeamNameFocused)
                                .animation(.easeInOut(duration: 0.2), value: vm.teamNameError != nil)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        .overlay(alignment: .bottomLeading) {
                            Text(vm.teamNameError ?? "")
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.Status.red)
                                .opacity(vm.teamNameError != nil ? 1 : 0)
                                .offset(x: 8, y: 19)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)

                    // MARK: - Add People Section
                    
                    Text("Add people to your team")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                    // MARK: - Search Field
                    
                    EmailSearchFieldView(
                        email: $vm.searchEmail,
                        onClear: { vm.searchEmail = "" },
                        isFocused: _isSearchFocused
                    )
                    .overlay(alignment: .top) {
                        
                        // Search results dropdown.
                        if isSearchFocused && vm.searchEmail.count >= 3 {
                            SearchResultsDropdown(
                                results: vm.searchResults,
                                onSelect: { user in
                                    vm.addMember(user)
                                    vm.searchEmail = ""
                                }
                            )
                            .offset(y: 52)
                            .shadow(radius: 10)
                            .transition(
                                .opacity.combined(with: .move(edge: .top))
                            )
                        }
                    }
                    .zIndex(1)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    // MARK: - Suggested Users
                    
                    if !vm.suggestedUsers.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            
                            Text("Suggested people")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppColors.Text.primary)
                                .padding(.horizontal, 20)

                            HStack(alignment: .top) {
                                ForEach(vm.suggestedUsers) { user in
                                    
                                    Button {
                                        withAnimation(
                                            .spring(
                                                response: 0.3,
                                                dampingFraction: 0.7
                                            )
                                        ) {
                                            vm.addMember(user)
                                        }
                                    } label: {
                                        VStack(spacing: 6) {
                                            
                                            UserAvatarView(
                                                user: user,
                                                size: 58,
                                                showBorder: false
                                            )
                                            
                                            Text(user.username)
                                                .font(.system(size: 12))
                                                .foregroundStyle(AppColors.Text.primary)
                                                .multilineTextAlignment(.center)
                                                .frame(maxWidth: .infinity)
                                                .lineLimit(2)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .frame(maxWidth: .infinity)
                                }
                                
                                if vm.suggestedUsers.count < 4 {
                                    ForEach(
                                        0..<(4 - vm.suggestedUsers.count),
                                        id: \.self
                                    ) { _ in
                                        Spacer()
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 24)

                    } else if nonOwnerMembers.isEmpty {

                        // Empty state when no teammates exist.
                        Text("Search for teammates and\nadd them to the list.")
                            .font(.system(size: 17))
                            .foregroundStyle(AppColors.Text.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 10)
                            .lineSpacing(4)
                            .tracking(0.2)
                            .padding(.bottom, 28)
                    }

                    // MARK: - Member List
                    
                    if !vm.members.isEmpty {
                        
                        Text("Member list")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.Text.primary)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        VStack(spacing: 0) {

                        // MARK: - Owner Row

                            if let owner {
                                OwnerRowView(user: owner)

                                if !nonOwnerMembers.isEmpty {
                                    Divider()
                                }
                            }

                            // MARK: - Team Members

                            if !nonOwnerMembers.isEmpty {
                                ForEach(
                                    Array(nonOwnerMembers.enumerated()),
                                    id: \.element.id
                                ) { index, user in

                                    UserRowView(
                                        user: user,
                                        onRemove: {
                                            vm.removeMember(user)
                                        }
                                    )

                                    if index != nonOwnerMembers.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .background(Color.appBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 40)
            }

            // MARK: - Toast Overlay
            
            .overlay(alignment: .bottom) {
                if let toast = vm.currentToast {
                    ToastView(toast: toast)
                        .padding(.bottom, 32)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom)
                                    .combined(with: .opacity),
                                removal: .opacity
                                    .combined(with: .scale(scale: 0.95))
                            )
                        )
                }
            }
            .animation(
                .spring(response: 0.45, dampingFraction: 0.75),
                value: vm.currentToast
            )
        }
        .portraitOrientationLock()

        // MARK: - Navigation
        
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)

        // MARK: - Search Listener
        
        .onChange(of: vm.searchEmail) { _, _ in
            Task {
                await vm.performSearch()
            }
        }

        // MARK: - Toolbar
        
        .toolbar {

            // Cancel button.
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    coordinator.pop()
                }
            }

            // Confirm button.
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm", systemImage: "checkmark") {
                    Task {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )

                        let success = await vm.confirmCreate()

                        if success {

                            // Show success toast.
                            vm.showToast(
                                Toast(
                                    message: "Team created successfully",
                                    type: .success
                                )
                            )
                            try? await Task.sleep(for: .seconds(1.2))

                            onConfirm()
                            coordinator.pop()
                        }
                    }
                }
                .tint(AppColors.Brand.primaryOrange)
                .disabled(
                    vm.isLoading || nonOwnerMembers.isEmpty
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CreateTeamScreen(
            viewModel: CreateTeamViewModel(
                createTeamUseCase: CreateTeamUseCase(
                    teamRepository: TeamRepositoryImpl(
                        teamDatasource: TeamDatasource(),
                        userDatasource: UserDatasource()
                    )
                ),
                userRepository: UserRepositoryImpl(
                    userDatasource: UserDatasource()
                ),
                teamRepository: TeamRepositoryImpl(
                    teamDatasource: TeamDatasource(),
                    userDatasource: UserDatasource()
                ),
                authRepository: AuthRepositoryImpl(
                    source: AuthFirebaseDatasource()
                )
            ),
            onConfirm: {}
        )
    }
    .environment(AppCoordinator())
}
