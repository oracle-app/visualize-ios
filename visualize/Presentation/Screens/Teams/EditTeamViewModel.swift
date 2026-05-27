//
//  EditTeamViewModel.swift
//  visualize
//
//  Created by Diana Escalante on 26/05/26.
//

//
/// ViewModel for the Edit Team sheet.
/// Handles searching users by email, adding and removing members,
/// and persisting the updated members list to the team.
//
 
import SwiftUI
import Observation
import Foundation
 
@MainActor
@Observable
final class EditTeamViewModel {
    
    // MARK: - Dependencies
    
    private let teamRepository: any TeamRepository
    private let userRepository: any UserRepository
    
    // MARK: - Constants
    
    private let teamID: String
    private let ownerID: String
    
    // MARK: - Input State
    
    /// Current text in the email search field.
    /// Setting this value automatically schedules a debounced user search.
    var email: String = "" {
        didSet {
            scheduleSearch()
        }
    }
    
    // MARK: - UI State
    
    private(set) var members: [AppUser] = []
    private(set) var suggestedUsers: [AppUser] = []
    private(set) var isLoading = false
    private(set) var currentToast: Toast?
    private(set) var error: String?
    
    /// Search task used for debounce.
    private var searchTask: Task<Void, Never>?
    
    @ObservationIgnored
    private var toastTask: Task<Void, Never>?

    // MARK: - Computed
    /// The team owner, if present in the members list.
    var owner: AppUser? {
        members.first { $0.id == ownerID }
    }

    /// All members except the owner.
    var nonOwnerMembers: [AppUser] {
        members.filter { $0.id != ownerID }
    }
 
    // MARK: - Init
 
    /// - Parameters:
    ///   - teamRepository: Repository used to persist the updated members list.
    ///   - userRepository: Repository used to search for users by email.
    ///   - teamID: The ID of the team being edited.
    ///   - ownerID: The team owner's ID, kept in the list and not removable.
    ///   - initialMembers: Current members of the team, shown on open.
    init(
        teamRepository: any TeamRepository,
        userRepository: any UserRepository,
        teamID: String,
        ownerID: String,
        initialMembers: [AppUser] = []
    ) {
        self.teamRepository = teamRepository
        self.userRepository = userRepository
        self.teamID = teamID
        self.ownerID = ownerID
        self.members = initialMembers
    }
 
    // MARK: - Search Logic (Debounce)
 
    /// Cancels any pending search and schedules a new one after a debounce delay.
    private func scheduleSearch() {
        searchTask?.cancel()
        guard email.count >= 3 else {
            suggestedUsers = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            if !Task.isCancelled {
                await performSearch()
            }
        }
    }
 
    /// Executes the email search and updates `suggestedUsers`, excluding current members.
    private func performSearch() async {
        let query = email
        isLoading = true
        defer { isLoading = false }
        do {
            let results = try await userRepository.getUserSuggestionsByEmail(email: query)
            guard query == email else { return }
            suggestedUsers = results.filter { candidate in
                !members.contains(where: { $0.id == candidate.id })
            }
        } catch {
            showToast("Failed to search users", type: .error)
        }
    }
    
    // MARK: - Toast

    /// Shows a toast and auto-dismisses it after a short delay.
    private func showToast(_ message: String, type: ToastType) {
        toastTask?.cancel()
        currentToast = Toast(message: message, type: type)
        toastTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            if !Task.isCancelled {
                currentToast = nil
            }
        }
    }
 
    // MARK: - Actions
 
    /// Adds a user to the members list and clears the search state.
    func addUser(_ user: AppUser) {
        if !members.contains(where: { $0.id == user.id }) {
            members.append(user)
        }
        email = ""
        suggestedUsers = []
    }
 
    /// Removes a user from the members list.
    /// The owner cannot be removed.
    func removeUser(_ user: AppUser) {
        guard user.id != ownerID else { return }
        members.removeAll { $0.id == user.id }
    }
 
    /// Returns whether the given user is the team owner.
    func isOwner(_ user: AppUser) -> Bool {
        user.id == ownerID
    }
 
    /// Clears the email input and dismisses any suggestions.
    func clearEmail() {
        email = ""
        suggestedUsers = []
    }
 
    /// Persists the current members list, updating only the team's `membersIDs`.
    /// The owner is excluded so it is not written back into `membersIDs`.
    func confirmChanges() async throws {
        do {
            let membersIDs = nonOwnerMembers.map { $0.id }
            try await teamRepository.updateTeamMembers(teamID: teamID, membersIDs: membersIDs)
        } catch {
            showToast("Failed to update team", type: .error)
            throw error
        }
    }
}
