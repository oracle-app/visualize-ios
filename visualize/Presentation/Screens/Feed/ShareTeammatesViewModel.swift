//
//  ShareTeammatesViewModel.swift
//  Visualize
//
//  Created by Diana Escalante on 13/04/26.
//

//
/// ViewModel that manages the business logic for sharing teammates.
/// Handles data loading, search filtering, and user selection/removal.
/// Maintains UI state and communicates with the service layer to fetch users.
//

import SwiftUI
import Observation
import Foundation

/// Manages state and logic for the share teammates flow.
@Observable
class ShareTeammatesViewModel {
    // MARK: - Dependencies
    private let teamRepository: any TeamRepository
    private let userRepository: any UserRepository
    
    // MARK: - UseCase
    private let updateSharingUseCase: UpdateSharingUseCase
    
    // MARK: IDs
    // Temporary hardcoded user ID, will be replaced with authenticated session value.
    private let userID = "e9Nk8XrxHJAtwN3Hf2FL"
//    private let userID = "oEJtQz0gdbRpTZ8ETPCy"
    private let initialTeamIDs: [String]
    private let visualizationID: String
    
    // MARK: - Input State

    /// Current text in the email search field.
    /// Setting this value automatically schedules a debounced user search.
    var email: String = "" {
        didSet {
            scheduleSearch() /// Every text change triggers the debounce timer
        }
    }
    
    // MARK: - UI State
    /// Users state
    var selectedUsers: [AppUser] = []
    var suggestedUsers: [AppUser] = []
    
    /// Teams state
    var myTeams: [Team] = []
    var joinedTeams: [Team] = []
    var selectedTeamIDs: Set<String> = []
    var isTeamsLoading = false
    
    /// Loading and error state
    var isLoading = false
    var error: String?
    /// Search task used for debounce
    private var searchTask: Task<Void, Never>?
    // MARK: - Initialization
    /// - Parameters:
    ///   - userRepository: Repository used to search for users by email.
    ///   - teamRepository: Repository used to fetch teams.
    ///   - updateSharingUseCase: Use case that persists both shared users and teams.
    ///   - visualizationID: The ID of the visualization being shared.
    ///   - initialUsers: Users already sharing the visualization, shown on open.
    ///   - initialTeamIDs: Team IDs that already have access, pre-selected on open.
    init(
        userRepository: any UserRepository,
        teamRepository: any TeamRepository,
        updateSharingUseCase: UpdateSharingUseCase,
        visualizationID: String,
        initialUsers: [AppUser] = [],
        initialTeamIDs: [String] = []
    ) {
        self.userRepository = userRepository
        self.teamRepository = teamRepository
        self.updateSharingUseCase = updateSharingUseCase
        self.visualizationID = visualizationID
        self.selectedUsers = initialUsers
        self.initialTeamIDs = initialTeamIDs
    }
    // MARK: - Search Logic (Debounce)
    /// Cancels any pending search and schedules a new one after a debounce delay.
    private func scheduleSearch() {
        searchTask?.cancel() // Cancel previous search if user keeps typing
        guard email.count >= 3 else {
            self.suggestedUsers = []
            return
        }
        searchTask = Task {
            /// Wait before firing the request to avoid querying on every keystroke
            try? await Task.sleep(for: .milliseconds(500))
            if !Task.isCancelled {
                await performSearch()
            }
        }
    }
    /// Executes the email search and updates `suggestedUsers`, excluding already selected ones.
    @MainActor
    private func performSearch() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let results = try await userRepository.getUserSuggestionsByEmail(email: email)
            self.suggestedUsers = results.filter { candidate in
                !selectedUsers.contains(where: { $0.id == candidate.id })
            }
        } catch {
            self.error = "Failed to search users"
        }
    }
    // MARK: - Actions
    /// Adds a user to the selected list and clears the search state.
    /// - Parameters:
    ///   - user: The `AppUser` to add.
    func addUser(_ user: AppUser) {
        if !selectedUsers.contains(where: { $0.id == user.id }) {
            selectedUsers.append(user)
        }
        email = "" // Clear search after adding
        suggestedUsers = []
    }
    /// Removes a user from the selected list.
    /// - Parameters:
    ///   - user: The `AppUser` to remove.
    func removeUser(_ user: AppUser) {
        selectedUsers.removeAll { $0.id == user.id }
    }
    /// Persists the current `selectedUsers` list to Firestore, replacing the previous one.
    func confirmShare() async throws {
        let selectedTeams = (myTeams + joinedTeams).filter { selectedTeamIDs.contains($0.id) }
        let result = try await updateSharingUseCase.execute(
            visualizationID: visualizationID,
            users: selectedUsers,
            teamIDs: Array(selectedTeamIDs),
            teams: selectedTeams
        )
        self.selectedUsers = result.users
        self.selectedTeamIDs = Set(result.teamIDs)
    }
    /// Clears the email input and dismisses any suggestions.
    func clearEmail() {
        email = ""
        suggestedUsers = []
    }
    
    /// Fetches teams owned by and joined by the current user,
    /// and pre-selects those already sharing this visualization.
    @MainActor
    func loadTeams() async {
        isTeamsLoading = true
        defer { isTeamsLoading = false }
        do {
            async let myTeamsRequest = teamRepository.getTeamsUserOwns(userID: userID)
            async let joinedTeamsRequest = teamRepository.getTeamsUserIsIn(userID: userID)
            myTeams = try await myTeamsRequest
            joinedTeams = try await joinedTeamsRequest
            selectedTeamIDs = Set(initialTeamIDs)
        } catch {
            self.error = "Error loading teams"
        }
    }

    /// Toggles the selection state of a team by its ID.
    /// - Parameter team: The team to select or deselect.
    func toggleSelection(_ team: Team) {
        if selectedTeamIDs.contains(team.id) {
            selectedTeamIDs.remove(team.id)
        } else {
            selectedTeamIDs.insert(team.id)
        }
    }

    /// Returns whether the given team is currently selected.
    /// - Parameter team: The team to check.
    /// - Returns: `true` if the team is selected, otherwise `false`.
    func isSelected(_ team: Team) -> Bool {
        selectedTeamIDs.contains(team.id)
    }
    
    /// Temporary helper for current user ID
    private func getCurrentUserID() -> String {
        // This should come from an AuthRepository
        return "current_user_id"
    }
}
