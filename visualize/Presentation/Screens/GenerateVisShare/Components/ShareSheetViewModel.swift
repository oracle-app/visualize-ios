//
//  ShareSheetViewModel.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 11/04/26.
//

import SwiftUI
import Observation
import Foundation

// MARK: - Share Sheet ViewModel

/// ViewModel responsible for managing the state and business interaction
/// of the Share Sheet screen.
///
/// This class:
/// - Stores the email input and debounces user search requests.
/// - Manages selected users and teams for sharing.
/// - Loads teams owned by and joined by the current user.
/// - Coordinates search, selection, and confirm-share actions.
///
@Observable
@MainActor
final class ShareSheetViewModel {

    // MARK: - Dependencies

    private let teamRepository: any TeamRepository
    private let userRepository: any UserRepository

    // Temporary hardcoded user ID, will be replaced with authenticated session value.
    private let userID = "e9Nk8XrxHJAtwN3Hf2FL"

    // MARK: - Input State

    /// Current text in the email search field.
    /// Setting this value automatically schedules a debounced user search.
    var email: String = "" {
        didSet {
            scheduleSearch()
        }
    }

    // MARK: - UI State

    var selectedUsers: [AppUser] = []
    var suggestedUsers: [AppUser] = []
    var myTeams: [Team] = []
    var joinedTeams: [Team] = []
    var selectedTeamIDs: Set<String> = []
    var isLoading = false
    var error: String?

    // MARK: - Private State

    private var searchTask: Task<Void, Never>?

    // MARK: - Initialization

    /// Initializes the ViewModel with its required repositories.
    ///
    /// - Parameters:
    ///   - teamRepository: Repository used to fetch teams.
    ///   - userRepository: Repository used to search users by email.
    init(teamRepository: any TeamRepository, userRepository: any UserRepository) {
        self.teamRepository = teamRepository
        self.userRepository = userRepository
    }

    // MARK: - Data Loading

    /// Fetches the teams owned by and joined by the current user concurrently.
    ///
    /// Guards against duplicate in-flight requests. Sets `isLoading` during
    /// the fetch and populates `myTeams` and `joinedTeams` on success,
    /// or sets `error` on failure.
    func loadData() {
        guard !isLoading else { return }

        Task {
            isLoading = true
            error = nil

            do {
                async let myTeamsRequest = teamRepository.getTeamsUserOwns(userID: userID)
                async let joinedTeamsRequest = teamRepository.getTeamsUserIsIn(userID: userID)

                myTeams = try await myTeamsRequest
                joinedTeams = try await joinedTeamsRequest
            } catch {
                self.error = "Error loading teams: \(error.localizedDescription)"
            }

            isLoading = false
        }
    }

    // MARK: - Actions

    /// Adds a user to the selected list if not already present, then clears the search field.
    func addUser(_ user: AppUser) {
        guard !selectedUsers.contains(where: { $0.id == user.id }) else { return }
        selectedUsers.append(user)
        email = ""
        suggestedUsers = []
    }

    /// Removes a user from the selected list.
    func removeUser(_ user: AppUser) {
        selectedUsers.removeAll { $0.id == user.id }
    }

    /// Toggles the selection state of a team by its ID.
    func toggleSelection(_ team: Team) {
        if selectedTeamIDs.contains(team.id) {
            selectedTeamIDs.remove(team.id)
        } else {
            selectedTeamIDs.insert(team.id)
        }
    }

    /// Returns whether the given team is currently selected.
    func isSelected(_ team: Team) -> Bool {
        selectedTeamIDs.contains(team.id)
    }

    /// Clears the email field and any active search suggestions.
    func clearEmail() {
        email = ""
        suggestedUsers = []
    }

    /// Confirms the share action and logs the selection summary.
    func confirmShare() {
        print("Sharing with \(selectedUsers.count) users and \(selectedTeamIDs.count) teams.")
    }

    // MARK: - Search Logic

    /// Cancels any pending search and schedules a new one with a 500 ms debounce.
    /// Clears suggestions immediately if the email is fewer than 3 characters.
    private func scheduleSearch() {
        searchTask?.cancel()

        guard email.count >= 3 else {
            suggestedUsers = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    /// Executes the user search and filters out already-selected users from results.
    private func performSearch() async {
        do {
            let results = try await userRepository.getUserSuggestionsByEmail(email: email)
            suggestedUsers = results.filter { candidate in
                !selectedUsers.contains(where: { $0.id == candidate.id })
            }
        } catch {
            print("Search error: \(error)")
        }
    }
}
