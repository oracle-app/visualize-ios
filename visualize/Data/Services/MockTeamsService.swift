//
//  MockTeamsService.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 22/04/26.
//
// Mock service that provides sample team data.
// Simulates asynchronous fetching without relying on a backend.
//

final class MockTeamsService: TeamsServiceProtocol {
    
    func fetchMyTeams() async throws -> [Team] {
        [
            Team(name: "Data Analyst", members: 2),
            Team(name: "Product Team", members: 5)
        ]
    }
    
    func fetchJoinedTeams() async throws -> [Team] {
        [
            Team(name: "Marketing", members: 5),
            Team(name: "Finance", members: 3)
        ]
    }
}
