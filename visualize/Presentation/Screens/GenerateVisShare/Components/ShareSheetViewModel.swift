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
    private let createVisualizationUseCase: CreateVisualizationUseCase

    // Temporary hardcoded user ID, will be replaced with authenticated session value.
    private let userID = "rcONSHwWXHbUo3NsO6bhg0J4D8u2"
    
    // MARK: - Chart Data
 
    /// Title of the selected chart suggestion, potentially edited by the user in VizReady.
    let chartTitle: String
    /// Full JSON string saved as `configJSON` in Firestore for use in `FullScreenView`.
    let chartConfigJSON: String
    /// Reduced JSON string saved as `previewJSON` in Firestore for use in feed card previews.
    let chartPreviewJSON: String

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
    /// Non-nil when `confirmShare` fails. Displayed in `ShareSheet` so the user knows the save failed.
    var confirmError: String? = nil


    // MARK: - Private State

    private var searchTask: Task<Void, Never>?

    // MARK: - Initialization

    /// Initializes the ViewModel with its required repositories.
    ///
    /// - Parameters:
    ///   - teamRepository: Repository used to fetch teams.
    ///   - userRepository: Repository used to search users by email.
    ///   - createVisualizationUseCase: Use case that persists the visualization on confirmation.
    ///   - chartTitle: Title of the chart the user selected in VizReady.
    ///   - chartConfigJSON: Full chart JSON to save as `configJSON` in Firestore.
    ///   - chartPreviewJSON: Reduced chart JSON to save as `previewJSON` in Firestore.
    init(
        teamRepository: any TeamRepository,
        userRepository: any UserRepository,
        createVisualizationUseCase: CreateVisualizationUseCase,
        chartTitle: String,
        chartConfigJSON: String,
        chartPreviewJSON: String
    ) {
        self.teamRepository = teamRepository
        self.userRepository = userRepository
        self.createVisualizationUseCase = createVisualizationUseCase
        self.chartTitle = chartTitle
        self.chartConfigJSON = chartConfigJSON
        self.chartPreviewJSON = chartPreviewJSON
    }

    // MARK: - Data Loading

    /// Fetches the teams owned by and joined by the current user concurrently.
    ///
    /// Guards against duplicate in-flight requests. Sets `isLoading` during
    /// the fetch and populates `myTeams` and `joinedTeams` on success.
    func loadData() {
        guard !isLoading else { return }

        Task {
            isLoading = true
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

    /// Creates the visualization in Firestore with both JSON fields and the current sharing selection.
    /// For personal feed: `selectedUsers` and `selectedTeamIDs` are both empty.
    /// For teammates: populated with the user's selections from the sheet.
    /// - Throws: Any error from `CreateVisualizationUseCase`.
    func confirmShare() async throws {
        confirmError = nil
        try await createVisualizationUseCase.execute(
            title: chartTitle,
            authorID: userID,
            configJSON: chartConfigJSON,
            previewJSON: chartPreviewJSON,
            users: selectedUsers,
            teamIDs: Array(selectedTeamIDs)
        )
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
