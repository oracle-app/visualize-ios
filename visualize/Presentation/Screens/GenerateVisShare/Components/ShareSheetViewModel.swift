import SwiftUI
import Observation
import Foundation

@Observable
final class ShareSheetViewModel {
    
    // MARK: - Dependencies
    // We use protocols to keep things decoupled and make testing easier
    private let teamRepository: any TeamRepository
    private let userRepository: any UserRepository
    private let userID = "e9Nk8XrxHJAtwN3Hf2FL"
    
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
    
    // Team lists
    var myTeams: [Team] = []
    var joinedTeams: [Team] = []
    
    // Selected team IDs
    var selectedTeamIDs: Set<String> = []
    
    // Loading and error state
    var isLoading = false
    var error: String?
    
    // Search task used for debounce
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(teamRepository: any TeamRepository, userRepository: any UserRepository) {
        self.teamRepository = teamRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Data Loading
    func loadData() {
        // Prevent duplicate loading if already in progress
        guard !isLoading else { return }
        
        Task {
            isLoading = true
            error = nil
            
            do {
                // Run requests in parallel for better performance
                async let myTeamsRequest = teamRepository.getTeamsUserOwns(userID: userID)
                async let joinedTeamsRequest = teamRepository.getTeamsUserIsIn(userID: userID)
                
                // Await results
                self.myTeams = try await myTeamsRequest
                self.joinedTeams = try await joinedTeamsRequest
                
            } catch {
                self.error = "Error loading teams: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
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
        do {
            // Call repository using Firebase \u{f8ff} prefix filtering
            let results = try await userRepository.getUserSuggestionsByEmail(email: email)
            
            // Filter out already selected users
            self.suggestedUsers = results.filter { candidate in
                !selectedUsers.contains(where: { $0.id == candidate.id })
            }
        } catch {
            print("Search error: \(error)")
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
    
    func toggleSelection(_ team: Team) {
        if selectedTeamIDs.contains(team.id) {
            selectedTeamIDs.remove(team.id)
        } else {
            selectedTeamIDs.insert(team.id)
        }
    }
    
    func isSelected(_ team: Team) -> Bool {
        selectedTeamIDs.contains(team.id)
    }
    
    func confirmShare() {
        // Final sharing logic using selectedUsers and selectedTeamIDs would go here
        print("Sharing with \(selectedUsers.count) users and \(selectedTeamIDs.count) teams")
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
