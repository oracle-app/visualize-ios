//
//  TeamsViewModel.swift
//  visualize
//
//  Created by Diana Escalante on 18/05/26.
//

//
/// ViewModel for TeamsScreen.
/// Handles loading, deleting, and editing teams.
/// Separates teams owned by the user from teams the user belongs to.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class TeamsScreenViewModel {

    // MARK: - State

    private(set) var myTeams: [Team] = []
    private(set) var joinedTeams: [Team] = []
    private(set) var isLoading = false
    private(set) var error: String?
    
    var showDeleteConfirmation = false
    private(set) var teamPendingDelete: Team?
    var teamToEdit: Team?

    // MARK: - Dependencies

    private let teamRepository: any TeamRepository
    private let authRepository: any AuthRepository
    private let userRepository: any UserRepository
    private var userID: String = ""

    // MARK: - Init

    init(
        teamRepository: any TeamRepository,
        authRepository: any AuthRepository,
        userRepository: any UserRepository
    ) {
        self.teamRepository = teamRepository
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Loading

    func loadTeams() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            userID = try await authRepository.getCurrentUserID()

            async let ownedRequest = teamRepository.getTeamsUserOwns(userID: userID)
            async let joinedRequest = teamRepository.getTeamsUserIsIn(userID: userID)

            myTeams = try await ownedRequest
            joinedTeams = try await joinedRequest
        } catch {
            self.error = "Failed to load teams."
        }
    }
    
    // MARK: - Delete

    func deleteTeam(_ team: Team) {
        teamPendingDelete = team
        showDeleteConfirmation = true
    }

    func confirmDelete() {
        guard let team = teamPendingDelete else { return }
        Task {
            do {
                try await teamRepository.deleteTeam(teamID: team.id)
                myTeams.removeAll { $0.id == team.id }
            } catch {
                self.error = "Failed to delete team."
            }
            teamPendingDelete = nil
        }
    }
    
    // MARK: - Edit

    /// Placeholder for navigation or sheet presentation to edit a team.
    func beginEditing(_ team: Team) {
        teamToEdit = team
    }
    
    /// Builds the view model for the edit team sheet for the given team.
    func makeEditViewModel(for team: Team) -> EditTeamViewModel {
        EditTeamViewModel(
            teamRepository: teamRepository,
            userRepository: userRepository,
            teamID: team.id,
            ownerID: userID,
            initialMembers: team.members
        )
    }
    
    /// Reloads teams after the edit team sheet confirms changes.
    func didFinishEditing() {
        Task { await loadTeams() }
    }
    
    // MARK: - Create

    /// Placeholder for navigation or sheet presentation to create a team.
    func beginCreating() {
        // TODO: Navigate to create new team screen
    }
}
