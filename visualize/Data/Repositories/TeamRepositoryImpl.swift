//
//  TeamsRepositoryImpl.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

class TeamRepositoryImpl: TeamRepository {
    private let teamDatasource: TeamDatasource
    private let userDatasource: UserDatasource
    
    init(teamDatasource: TeamDatasource, userDatasource: UserDatasource) {
        self.teamDatasource = teamDatasource
        self.userDatasource = userDatasource
    }
    
    func getTeamsUserOwns(userID: String) async throws -> [Team] {
        let teamsDTOs = try await teamDatasource.getTeamsUserOwns(userID: userID)
        let allMemberIDs = Set(teamsDTOs.flatMap { $0.membersIDs + [$0.ownerID] })
        let usersDTOs = try await userDatasource.getUsers(byIDs: Array(allMemberIDs))
        let usersDict = Dictionary(uniqueKeysWithValues: usersDTOs.map { ($0.id, $0.toAppUser()) })
        return teamsDTOs.map { teamDTO in
            let memberIDs = teamDTO.membersIDs.filter { $0 != teamDTO.ownerID } + [teamDTO.ownerID]
            let members = memberIDs.compactMap { usersDict[$0] }
            return teamDTO.toTeam(members: members)
        }
    }
    
    func getTeamsUserIsIn(userID: String) async throws -> [Team] {
        let teamsDTOs = try await teamDatasource.getTeamsUserIsIn(userID: userID)
        let allMemberIDs = Set(teamsDTOs.flatMap { $0.membersIDs + [$0.ownerID] })
        let usersDTOs = try await userDatasource.getUsers(byIDs: Array(allMemberIDs))
        let usersDict = Dictionary(uniqueKeysWithValues: usersDTOs.map { ($0.id, $0.toAppUser()) })
        return teamsDTOs.map { teamDTO in
            let memberIDs = [teamDTO.ownerID] + teamDTO.membersIDs.filter { $0 != teamDTO.ownerID }
            let members = memberIDs.compactMap { usersDict[$0] }
            return teamDTO.toTeam(members: members)
        }
    }
    
    func createTeam(name: String, ownerID: String, initialMembers: [String]) async throws {
        let newTeam = TeamDTO(
            name: name,
            ownerID: ownerID,
            membersIDs: initialMembers
        )
        do {
            try await teamDatasource.createTeam(newTeam: newTeam)
        } catch {
            throw error
        }
    }
    
    func updateTeamMembers(teamID: String, membersIDs: [String]) async throws {
        do {
            try await teamDatasource.updateTeamMembers(teamID: teamID, membersIDs: membersIDs)
        } catch {
            throw error
        }
    }
    
    func deleteTeam(teamID: String) async throws {
        do {
            try await teamDatasource.deleteTeam(teamID: teamID)
        } catch {
            throw error
        }
    }
}
