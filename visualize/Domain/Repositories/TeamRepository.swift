//
//  TeamsRepository.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

protocol TeamRepository {
    func getTeamsUserIsIn(userID: String) async throws -> [Team]
    
    func getTeamsUserOwns(userID: String) async throws -> [Team]
    
    func createTeam(name: String, ownerID: String, initialMembers: [String]) async throws
    
    func deleteTeam(teamID: String) async throws
}
