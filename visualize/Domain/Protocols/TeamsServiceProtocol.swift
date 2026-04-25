//
//  TeamsServiceProtocol.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 22/04/26.
//
// Protocol that defines the contract for fetching team data.
// Enables dependency injection and improves testability of the ViewModel.
//

protocol TeamsServiceProtocol {
    func fetchMyTeams() async throws -> [Team]
    func fetchJoinedTeams() async throws -> [Team]
}
