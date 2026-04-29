import SwiftUI
import Observation
import Foundation

@Observable
final class ShareSheetViewModel {
    // MARK: - Dependencies
    private let teamRepository: any TeamRepository
    private let userRepository: any UserRepository
    private let userID = "e9Nk8XrxHJAtwN3Hf2FL"
    
    // MARK: - State
    var email: String = "" {
        didSet {
            scheduleSearch()
        }
    }
    
    var selectedUsers: [AppUser] = []
    var suggestedUsers: [AppUser] = []
    var myTeams: [Team] = []
    var joinedTeams: [Team] = []
    var selectedTeamIDs: Set<String> = []
    var isLoading = false
    var error: String?
    
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(teamRepository: any TeamRepository, userRepository: any UserRepository) {
        self.teamRepository = teamRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Data Loading
    func loadData() {

        guard !isLoading else { return }
        
        Task {
            isLoading = true
            error = nil
            
            do {
                async let myTeamsRequest = teamRepository.getTeamsUserOwns(userID: userID)
                async let joinedTeamsRequest = teamRepository.getTeamsUserIsIn(userID: userID)
                
                self.myTeams = try await myTeamsRequest
                self.joinedTeams = try await joinedTeamsRequest
                
            } catch {
                self.error = "Error al cargar equipos: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Search Logic (Debounce)
    private func scheduleSearch() {
        searchTask?.cancel()
        
        guard email.count >= 3 else {
            self.suggestedUsers = []
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            
            if !Task.isCancelled {
                await performSearch()
            }
        }
    }
    
    @MainActor
    private func performSearch() async {
        do {
            let results = try await userRepository.getUserSuggestionsByEmail(email: email)
            
            self.suggestedUsers = results.filter { candidate in
                !selectedUsers.contains(where: { $0.id == candidate.id })
            }
        } catch {
            print("Error en búsqueda: \(error)")
        }
    }
    
    // MARK: - Actions
    func addUser(_ user: AppUser) {
        if !selectedUsers.contains(where: { $0.id == user.id }) {
            selectedUsers.append(user)
        }
        email = ""
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
        print("Compartiendo con \(selectedUsers.count) usuarios y \(selectedTeamIDs.count) equipos")
    }
    
    func clearEmail() {
        email = ""
        suggestedUsers = []
    }
    
    private func getCurrentUserID() -> String {
        return "current_user_id"
    }
}
