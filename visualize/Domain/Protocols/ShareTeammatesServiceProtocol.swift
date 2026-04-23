//
//  ShareTeammatesServiceProtocol.swift
//  visualize
//
//  Created by Diana Escalante on 22/04/26.
//

//
// Protocol that defines the contract for fetching users.
// Enables dependency injection and improves testability of the ViewModel.
//

protocol ShareTeammatesServiceProtocol {
    func fetchUsers() async throws -> [User]
}
