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
        let teamsOwnedByUserRaw = try await teamDatasource.getTeamsUserOwns(userID: userID)
        var finalTeams: [Team] = []
        for teamDTO in teamsOwnedByUserRaw {
            var members: [AppUser] = []
            for id in teamDTO.membersIDs {
                let userDTO = try await userDatasource.getUserByID(userID: id)
                members.append(userDTO.toAppUser())
            }
            let team = teamDTO.toTeam(members: members)
            finalTeams.append(team)
        }
        return finalTeams
    }
    func getTeamsUserIsIn(userID: String) async throws -> [Team] {
        let teamsDTOs = try await teamDatasource.getTeamsUserIsIn(userID: userID)
        var finalTeams: [Team] = []
        for teamDTO in teamsDTOs {
            var members: [AppUser] = []
            for id in teamDTO.membersIDs {
                let userDTO = try await userDatasource.getUserByID(userID: id)
                members.append(userDTO.toAppUser())
            }
            let team = teamDTO.toTeam(members: members)
            finalTeams.append(team)
        }
        return finalTeams
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
    func deleteTeam(teamID: String) async throws {
        do {
            try await teamDatasource.deleteTeam(teamID: teamID)
        } catch {
            throw error
        }
    }
}
