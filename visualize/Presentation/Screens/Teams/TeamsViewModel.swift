//
//  TeamsViewModel.swift
//  visualize
//
//  Created by Diana Escalante on 18/05/26.
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

    // MARK: - Dependencies

    private let teamRepository: any TeamRepository
    private let authRepository: any AuthRepository
    private var userID: String = ""

    // MARK: - Init

    init(teamRepository: any TeamRepository, authRepository: any AuthRepository) {
        self.teamRepository = teamRepository
        self.authRepository = authRepository
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
        // TODO: Present edit sheet for team
    }
}
