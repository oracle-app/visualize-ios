//
//  TeamsRepository.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

protocol TeamsRepository {
    func getTeamsUserIsIn(userID: String) async throws ->[Team]
    
    func getTeamsUserOwns(userID: String) async throws -> [Team]
}
