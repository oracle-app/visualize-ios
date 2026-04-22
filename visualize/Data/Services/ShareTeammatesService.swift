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
    
    func fetchUsers() async throws -> [User] {
        return [
            User(name: "Diana Escalante", email: "dianaescalante@email.com"),
            User(name: "Jocelyn Duarte", email: "jocelynduarte@email.com"),
            User(name: "Eduardo Salazar", email: "eduardosalazar@email.com"),
            User(name: "Ana Torres", email: "ana@email.com"),
            User(name: "Ana Lucia", email: "analucia@email.com"),
            User(name: "Carlos Ruiz", email: "carlos@email.com"),
            User(name: "María López", email: "maria@email.com"),
            User(name: "Luis García", email: "luis@email.com"),
        ]
    }
}
