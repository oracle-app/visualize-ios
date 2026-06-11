//
//  ShareSheetViewModel.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 11/04/26.
//

import SwiftUI
import Observation
import Foundation

// MARK: - Chart Publish Item
 
/// Lightweight container for the data needed to persist a single visualization to Firestore.
/// Used to pass one or more selected charts from VizReady into `ShareSheetViewModel`.
struct ChartPublishItem {
    /// User-facing title, potentially edited in VizReady.
    let title: String
    /// Full JSON string saved as `configJSON` in Firestore for FullScreenView.
    let configJSON: String
    /// Reduced JSON string saved as `previewJSON` in Firestore for feed card previews.
    let previewJSON: String
}

// MARK: - Share Sheet ViewModel

/// ViewModel responsible for managing the state and business interaction
/// of the Share Sheet screen.
///
/// This class:
/// - Stores the email input and debounces user search requests.
/// - Manages selected users and teams for sharing.
/// - Loads teams owned by and joined by the current user.
/// - Coordinates search, selection, and confirm-share actions.
/// - Supports publishing one or more charts in a single share action.

@MainActor
@Observable
final class ShareSheetViewModel {

    // MARK: - Dependencies

    private let teamRepository: any TeamRepository
    private let userRepository: any UserRepository
    private let authRepository: any AuthRepository
    private let createVisualizationUseCase: CreateVisualizationUseCase

    private(set) var userID: String = ""
    
    // MARK: - Chart Data
 
    /// Charts to publish when the user confirms. Supports batch publish (1 to N).
        let charts: [ChartPublishItem]

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
    var confirmError: String?

    // MARK: - Private State

    private var searchTask: Task<Void, Never>?

    // MARK: - Initialization

    /// Initializes the ViewModel with its required repositories.
    ///
    /// - Parameters:
    ///   - teamRepository: Repository used to fetch teams.
    ///   - userRepository: Repository used to search users by email.
    ///   - authRepository: Repository used to resolve the current user session.
    ///   - createVisualizationUseCase: Use case that persists the visualization on confirmation.
    ///   - charts: One or more charts to publish. Supports batch publish.
    
    init(
        teamRepository: any TeamRepository,
        userRepository: any UserRepository,
        authRepository: any AuthRepository,
        createVisualizationUseCase: CreateVisualizationUseCase,
        charts: [ChartPublishItem]
    ) {
        self.teamRepository = teamRepository
        self.userRepository = userRepository
        self.authRepository = authRepository
        self.createVisualizationUseCase = createVisualizationUseCase
        self.charts = charts
        Task {
            await initializeUser()
        }
    }
    
    private func initializeUser() async {
        do {
            self.userID = try await authRepository.getCurrentUserID()
        } catch {
            self.error = String(localized: "Couldn't get user session.")
        }
    }

    // MARK: - Data Loading

    /// Fetches the teams owned by and joined by the current user concurrently.
    ///
    /// Guards against duplicate in-flight requests. Sets `isLoading` during
    /// the fetch and populates `myTeams` and `joinedTeams` on success.
    func loadData() {
        guard !isLoading else { return }
        guard !userID.isEmpty else { return }
        Task {
            isLoading = true
            do {
                async let myTeamsRequest = teamRepository.getTeamsUserOwns(userID: userID)
                async let joinedTeamsRequest = teamRepository.getTeamsUserIsIn(userID: userID)
                myTeams = try await myTeamsRequest
                joinedTeams = try await joinedTeamsRequest
            } catch {
                self.error = String(localized: "Error loading teams: \(error.localizedDescription)")

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
        guard !userID.isEmpty else {
            confirmError = String(localized: "Session not valid.")
            return
        }
        
        confirmError = nil
        
        for chart in charts {
            try await createVisualizationUseCase.execute(
                title: chart.title,
                authorID: userID,
                configJSON: chart.configJSON,
                previewJSON: chart.previewJSON,
                users: selectedUsers,
                teamIDs: Array(selectedTeamIDs)
            )
        }
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
