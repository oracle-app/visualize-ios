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

@Observable
class ShareTeammatesViewModel {
    
    // MARK: - Dependencies
    // We use protocols to keep things decoupled and make testing easier
    private let userRepository: any UserRepository
    private let userID = "e9Nk8XrxHJAtwN3Hf2FL"
    // private let service: ShareTeammatesServiceProtocol
    
    // MARK: - State
    var email: String = "" {
        didSet {
            scheduleSearch() // Every text change triggers the debounce timer
        }
    }
    
    // Users currently selected for sharing
    var selectedUsers: [AppUser] = []
    
    // Suggestions fetched from the database after searching
    var suggestedUsers: [AppUser] = []
    
    // Loading and error state
    var isLoading = false
    var error: String?
    
    // Search task used for debounce
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(userRepository: any UserRepository, initialUsers: [AppUser] = []) {
        self.userRepository = userRepository
        self.selectedUsers = initialUsers
    }
    
    // MARK: - Search Logic (Debounce)
    private func scheduleSearch() {
        searchTask?.cancel() // Cancel previous search if user keeps typing
        
        guard email.count >= 3 else {
            self.suggestedUsers = []
            return
        }
        
        searchTask = Task {
            // Wait 500ms before triggering the Firebase request
            try? await Task.sleep(for: .milliseconds(500))
            
            if !Task.isCancelled {
                await performSearch()
            }
        }
    }
    
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
    func addUser(_ user: AppUser) {
        if !selectedUsers.contains(where: { $0.id == user.id }) {
            selectedUsers.append(user)
        }
        email = "" // Clear search after adding
        suggestedUsers = []
    }
    
    func removeUser(_ user: AppUser) {
        selectedUsers.removeAll { $0.id == user.id }
    }
    
    func confirmShare() {
        // Final sharing logic using selectedUsers would go here
        print("Sharing with \(selectedUsers.count) users")
    }
    
    func clearEmail() {
        email = ""
        suggestedUsers = []
    }
    
    // Temporary helper for current user ID
    private func getCurrentUserID() -> String {
        // This should come from an AuthRepository
        return "current_user_id"
    }
}


extension ShareTeammatesViewModel {
    static var preview: ShareTeammatesViewModel {
        ShareTeammatesViewModel(
            userRepository: UserRepositoryImpl(
                userDatasource: UserDatasource()
            )
        )
    }
}
