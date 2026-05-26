//
//  CreateTeamViewModel.swift
//  visualize
//
//  Created by Libia Fv on 18/05/26.
//

import SwiftUI
import Observation

// MARK: - ViewModel

/// ViewModel responsible for handling the business logic
/// of the Create Team flow.
///
/// Responsibilities:
/// - Manage team creation state
/// - Handle user search logic
/// - Validate form inputs
/// - Load suggested teammates
/// - Manage toast and error states
/// - Execute team creation use case
@Observable
class CreateTeamViewModel {

    // MARK: - Dependencies

    /// Use case responsible for creating a team.
    private let createTeamUseCase: CreateTeamUseCase

    /// Repository used to fetch user information.
    private let userRepository: any UserRepository

    /// Repository used to fetch team information.
    private let teamRepository: any TeamRepository

    /// Repository used for authentication operations.
    private let authRepository: any AuthRepository

    // MARK: - Input

    /// Team name entered by the user.
    ///
    /// Automatically re-validates if an error already exists.
    var teamName: String = "" {
        didSet {
            if teamNameError != nil {
                _ = validateTeamName()
            }
        }
    }

    /// Current search input for searching teammates by email.
    var searchEmail: String = ""

    // MARK: - State

    /// Current list of members in the team.
    ///
    /// The first member is always considered the owner.
    var members: [AppUser] = []

    /// Search results returned from the email search.
    var searchResults: [AppUser] = []

    /// Indicates whether an async operation is running.
    var isLoading = false

    // MARK: - UI State

    /// Validation error for the team name field.
    var teamNameError: String?

    /// Generic screen error.
    var error: String?

    /// Currently displayed toast.
    var currentToast: Toast?

    // MARK: - Ignored Observation Properties

    /// Background task used to automatically dismiss toasts.
    @ObservationIgnored
    private var toastTask: Task<Void, Never>?

    // MARK: - User State

    /// ID of the currently authenticated user.
    private(set) var currentUserID: String = ""

    // MARK: - Suggested Users Pool

    /// Internal pool of all possible teammate suggestions.
    ///
    /// Suggestions are filtered dynamically
    /// to avoid already selected members.
    private var allAvailableTeammates: [AppUser] = []

    // MARK: - Computed Properties

    /// Returns up to 4 suggested users
    /// that are not already part of the team.
    var suggestedUsers: [AppUser] {
        Array(
            allAvailableTeammates
                .filter { candidate in
                    !members.contains(where: { $0.id == candidate.id })
                }
                .prefix(4)
        )
    }

    // MARK: - Private State

    /// Debounced search task.
    ///
    /// Used to cancel previous searches
    /// while the user is typing.
    private var searchTask: Task<Void, Never>?

    // MARK: - Initialization

    init(
        createTeamUseCase: CreateTeamUseCase,
        userRepository: any UserRepository,
        teamRepository: any TeamRepository,
        authRepository: any AuthRepository
    ) {
        self.createTeamUseCase = createTeamUseCase
        self.userRepository = userRepository
        self.teamRepository = teamRepository
        self.authRepository = authRepository

        // Initialize authenticated user data.
        Task {
            await initializeUser()
        }
    }

    // MARK: - Toast Handling

    /// Displays a toast temporarily.
    ///
    /// Any existing toast task is cancelled before showing a new one.
    func showToast(_ toast: Toast) {
        toastTask?.cancel()

        currentToast = toast

        toastTask = Task {
            try? await Task.sleep(for: .seconds(3))

            guard !Task.isCancelled else { return }

            currentToast = nil
        }
    }

    // MARK: - User Initialization

    /// Loads the authenticated user
    /// and initializes teammate suggestions.
    @MainActor
    private func initializeUser() async {
        do {
            self.currentUserID = try await authRepository.getCurrentUserID()

            await loadSuggestedUsers()

        } catch {
            self.error = "Failed to authenticate user."
        }
    }

    // MARK: - Suggested Users

    /// Loads teammate suggestions based on:
    /// - Teams owned by the user
    /// - Teams the user belongs to
    ///
    /// Duplicates are automatically removed.
    @MainActor
    func loadSuggestedUsers() async {

        guard !currentUserID.isEmpty else { return }

        do {

            // Fetch owner information.
            let owner = try await userRepository.getUserByID(
                userID: currentUserID
            )

            // Ensure owner is the first member.
            if members.isEmpty {
                members = [owner]
            }

            // Fetch all related teams concurrently.
            async let ownedTeamsReq =
                teamRepository.getTeamsUserOwns(userID: currentUserID)

            async let joinedTeamsReq =
                teamRepository.getTeamsUserIsIn(userID: currentUserID)

            let ownedTeams = try await ownedTeamsReq
            let joinedTeams = try await joinedTeamsReq

            // Dictionary used for uniqueness.
            var uniqueUsers = [String: AppUser]()

            for team in (ownedTeams + joinedTeams) {
                for member in team.members
                where member.id != currentUserID {

                    uniqueUsers[member.id] = member
                }
            }

            self.allAvailableTeammates = Array(uniqueUsers.values)

        } catch {
            self.error = "Could not load suggested teammates."
        }
    }

    // MARK: - Search Logic

    /// Performs a debounced user search.
    ///
    /// Search only starts when:
    /// - Input contains at least 3 characters
    /// - User stops typing for 400ms
    @MainActor
    func performSearch() async {

        // Cancel previous pending search.
        searchTask?.cancel()

        guard searchEmail.count >= 3 else {
            searchResults = []
            return
        }

        searchTask = Task {

            // Debounce delay.
            try? await Task.sleep(for: .milliseconds(400))

            guard !Task.isCancelled else { return }

            await executeSearch()
        }
    }

    /// Executes the actual user search request.
    @MainActor
    private func executeSearch() async {

        isLoading = true
        defer { isLoading = false }

        do {

            let results =
                try await userRepository
                    .getUserSuggestionsByEmail(email: searchEmail)

            // Remove already selected members.
            searchResults = results.filter { candidate in
                !members.contains(where: { $0.id == candidate.id })
            }

        } catch {
            self.error = "Search failed. Please try again."
        }
    }

    // MARK: - Member Actions

    /// Adds a new member to the team.
    ///
    /// Duplicate members are ignored.
    func addMember(_ user: AppUser) {

        guard !members.contains(where: { $0.id == user.id }) else {
            return
        }

        members.append(user)

        // Remove from search results after adding.
        searchResults.removeAll { $0.id == user.id }
    }

    /// Removes a member from the team.
    ///
    /// The owner cannot be removed.
    func removeMember(_ user: AppUser) {

        // Prevent removing owner.
        guard members.first?.id != user.id else {
            return
        }

        members.removeAll { $0.id == user.id }
    }

    // MARK: - Validation

    /// Validates the team name field.
    ///
    /// Returns:
    /// - `true` if valid
    /// - `false` if invalid
    private func validateTeamName() -> Bool {

        if teamName
            .trimmingCharacters(in: .whitespaces)
            .isEmpty {

            teamNameError =
                "Required fields cannot be left blank."

            return false
        }

        teamNameError = nil

        return true
    }

    // MARK: - Team Creation

    /// Creates the team using the provided information.
    ///
    /// Returns:
    /// - `true` if creation succeeds
    /// - `false` if creation fails
    func confirmCreate() async -> Bool {

        // Validate inputs first.
        guard validateTeamName() else {
            return false
        }

        isLoading = true
        defer { isLoading = false }

        // Exclude owner from member list.
        let memberIDs = members.dropFirst().map(\.id)

        do {

            try await createTeamUseCase.execute(
                name: teamName,
                ownerID: currentUserID,
                memberIDs: memberIDs
            )

            return true

        } catch {

            showToast(
                Toast(
                    message: "Failed to create team. Please try again.",
                    type: .error
                )
            )

            return false
        }
    }
}
