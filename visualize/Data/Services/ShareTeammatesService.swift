//
//  ShareTeammatesService.swift
//  visualize
//
//  Created by DianaEscalante on 22/04/26.
//

//
// Service responsible for providing user data.
// Simulates an asynchronous data fetch, representing a database call.
//

class ShareTeammatesService: ShareTeammatesServiceProtocol {
    
    func fetchUsers() async throws -> [AppUser] {
        return [
            AppUser(id: "user_001", email: "dianaescalante@email.com", profilePictureURL: nil, username: "Diana Escalante"),
            AppUser(id: "user_002", email: "jocelynduarte@email.com", profilePictureURL: nil, username: "Jocelyn Duarte"),
            AppUser(id: "user_003", email: "eduardosalazar@email.com", profilePictureURL: nil, username: "Eduardo Salazar"),
            AppUser(id: "user_004", email: "ana@email.com", profilePictureURL: nil, username: "Ana Torres"),
            AppUser(id: "user_005", email: "analucia@email.com", profilePictureURL: nil, username: "Ana Lucia"),
            AppUser(id: "user_006", email: "carlos@email.com", profilePictureURL: nil, username: "Carlos Ruiz"),
            AppUser(id: "user_007", email: "maria@email.com", profilePictureURL: nil, username: "María López"),
            AppUser(id: "user_008", email: "luis@email.com", profilePictureURL: nil, username: "Luis García")
        ]
    }
}
