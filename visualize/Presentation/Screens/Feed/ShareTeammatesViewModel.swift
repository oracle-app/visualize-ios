import SwiftUI
internal import Combine

class ShareTeammatesViewModel: ObservableObject {
    
    @Published var email: String = ""
    
    @Published var users: [User] = [
        User(name: "Diana Escalante", email: "dianaescalante@email.com"),
        User(name: "Jocelyn Duarte", email: "jocelynduarte@email.com"),
        User(name: "Eduardo Salazar", email: "eduardosalazar@email.com"),
    ]
    
    private let allUsers: [User] = [
        User(name: "Ana Torres", email: "ana@email.com"),
        User(name: "Ana Lucia", email: "analucia@email.com"),
        User(name: "Carlos Ruiz", email: "carlos@email.com"),
        User(name: "María López", email: "maria@email.com"),
        User(name: "Luis García", email: "luis@email.com"),
    ]
    
    var filteredUsers: [User] {
        guard !email.isEmpty else { return [] }
        
        return allUsers.filter { candidate in
            
            let matchesSearch = candidate.email
                .localizedCaseInsensitiveContains(email)
            
            let alreadyAdded = users.contains {
                $0.email == candidate.email
            }
            
            return matchesSearch && !alreadyAdded
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
}
