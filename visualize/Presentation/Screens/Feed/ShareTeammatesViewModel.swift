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
    /// We use protocols to keep things decoupled and make testing easier
    private let userRepository: any UserRepository
    private let updateSharedUsersUseCase: UpdateSharedUsersUseCase
    private let userID = "e9Nk8XrxHJAtwN3Hf2FL"
    private let visualizationID: String
    
    // MARK: - State
    var email: String = "" {
        didSet {
            scheduleSearch() /// Every text change triggers the debounce timer
        }
    }
    
    /// Users currently selected for sharing
    var selectedUsers: [AppUser] = []
    
    /// Suggestions fetched from the database after searching
    var suggestedUsers: [AppUser] = []
    
    /// Loading and error state
    var isLoading = false
    var error: String?
    
    /// Search task used for debounce
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    /// - Parameters:
    ///   - userRepository: Repository used to search for users by email.
    ///   - updateSharedUsersUseCase: Use case that persists the shared users list.
    ///   - visualizationID: The ID of the visualization being shared.
    ///   - initialUsers: Users already sharing the visualization, shown on open.
    init(
        userRepository: any UserRepository,
        updateSharedUsersUseCase: UpdateSharedUsersUseCase,
        visualizationID: String,
        initialUsers: [AppUser] = []
    ) {
        self.userRepository = userRepository
        self.updateSharedUsersUseCase = updateSharedUsersUseCase
        self.visualizationID = visualizationID
        self.selectedUsers = initialUsers
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
        let updatedUsers = try await updateSharedUsersUseCase.execute(
            visualizationID: visualizationID,
            users: selectedUsers
        )
        // Reflect the confirmed state locally
        self.selectedUsers = updatedUsers
    }
    
    /// Clears the email input and dismisses any suggestions.
    func clearEmail() {
        email = ""
        suggestedUsers = []
    }
    
    /// Temporary helper for current user ID
    private func getCurrentUserID() -> String {
        // This should come from an AuthRepository
        return "current_user_id"
    }
}

