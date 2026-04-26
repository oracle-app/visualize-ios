//
//  ShareTeammatesViewModel.swift
//  Visualize
//
//  Created by Diana Escalante on 13/04/26.
//

//
// ViewModel that manages the business logic for sharing teammates.
// Handles data loading, search filtering, and user selection/removal.
// Maintains UI state and communicates with the service layer to fetch users.
//

import SwiftUI
import Observation

@Observable
class ShareTeammatesViewModel {
    var state: State = .loading
    var email: String = ""
        
    private let service: ShareTeammatesServiceProtocol
        
    init(service: ShareTeammatesServiceProtocol = ShareTeammatesService()) {
        self.service = service
    }
        
    enum State {
        case loading
        case loaded(users: [AppUser], selected: [AppUser])
        case error
    }
        
        
    var filteredUsers: [AppUser] {
        guard case let .loaded(users, selected) = state,
                !email.isEmpty else { return [] }
            
        return users.filter { candidate in
                
            let matches = candidate.email
                .localizedCaseInsensitiveContains(email)
                
            let alreadyAdded = selected.contains {
                $0.email == candidate.email
            }
                
            return matches && !alreadyAdded
        }
    }
        
        
    func loadData() {
        state = .loading
            
        Task {
            do {
                try await Task.sleep(nanoseconds: 500_000_000)
                let users = try await service.fetchUsers()
                    
                let initialSelected = Array(users.prefix(3))
                    
                state = .loaded(users: users, selected: initialSelected)
                    
            } catch {
                state = .error
            }
        }
    }
        
    func addUser(_ user: AppUser) {
        guard case let .loaded(users, selected) = state else { return }
            
        state = .loaded(
            users: users,
            selected: selected + [user]
        )
            
        email = ""
    }
        
    func removeUser(_ user: AppUser) {
        guard case let .loaded(users, selected) = state else { return }
            
        state = .loaded(
            users: users,
            selected: selected.filter { $0.email != user.email }
        )
    }
        
    func clearEmail() {
        email = ""
    }
}
