//
//  ShareSheetViewModel.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 22/04/26.
//
//
// ViewModel that manages the state and logic of the ShareSheet.
// Handles fetching users and teams, filtering search results,
// and managing selected users and teams.
//

import SwiftUI
import Observation
import Foundation

struct Team: Identifiable, Hashable {
    let id: UUID
    let name: String
    let members: Int
    
    init(id: UUID = UUID(), name: String, members: Int) {
        self.id = id
        self.name = name
        self.members = members
    }
}

@Observable
final class ShareSheetViewModel {
    
    private let usersService: ShareTeammatesServiceProtocol
    private let teamsService: TeamsServiceProtocol
    
    var email: String = ""
    var users: [User] = []
    var allUsers: [User] = []
    
    var myTeams: [Team] = []
    var joinedTeams: [Team] = []
    
    var selectedTeams: Set<UUID> = []
    
    var isLoading = false
    var error: String?
    
    init(
        usersService: ShareTeammatesServiceProtocol = ShareTeammatesService(),
        teamsService: TeamsServiceProtocol = MockTeamsService()
    ) {
        self.usersService = usersService
        self.teamsService = teamsService
    }
    
    var filteredUsers: [User] {
        guard !email.isEmpty else { return [] }
        
        return allUsers.filter { candidate in
            candidate.email.localizedCaseInsensitiveContains(email)
            && !users.contains(where: { $0.email == candidate.email })
        }
    }
    
    func loadData() {
        Task {
            isLoading = true
            error = nil
            
            do {
                async let users = usersService.fetchUsers()
                async let myTeams = teamsService.fetchMyTeams()
                async let joined = teamsService.fetchJoinedTeams()
                
                let fetchedUsers = try await users
                
                self.allUsers = fetchedUsers
                self.users = Array(fetchedUsers.prefix(2))
                self.myTeams = try await myTeams
                self.joinedTeams = try await joined
                
            } catch {
                self.error = "Failed to load data"
            }
            
            isLoading = false
        }
    }

    func addUser(_ user: User) {
        users.append(user)
        email = ""
    }
    
    func removeUser(_ user: User) {
        users.removeAll { $0.email == user.email }
    }
    
    func clearEmail() {
        email = ""
    }
    
    func toggleSelection(_ team: Team) {
        if selectedTeams.contains(team.id) {
            selectedTeams.remove(team.id)
        } else {
            selectedTeams.insert(team.id)
        }
    }
    
    func isSelected(_ team: Team) -> Bool {
        selectedTeams.contains(team.id)
    }

    func confirmShare() {
        // Placeholder: business logic to be implemented
    }
}
