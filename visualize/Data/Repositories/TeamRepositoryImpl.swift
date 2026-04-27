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
        // 1. Obtener los equipos (una sola petición)
        let teamsOwnedByUserRaw = try await teamDatasource.getTeamsUserOwns(userID: userID)
        
        var finalTeams: [Team] = []
        
        // 2. Procesar cada equipo uno por uno
        for teamDTO in teamsOwnedByUserRaw {
            var members: [AppUser] = []
            
            // 3. Obtener los miembros de este equipo uno por uno
            for id in teamDTO.membersIDs {
                let userDTO = try await userDatasource.getUserByID(userID: id)
                members.append(userDTO.toAppUser())
            }
            
            // 4. Convertir a modelo de dominio y guardar
            let team = teamDTO.toTeam(members: members)
            finalTeams.append(team)
        }
        
        return finalTeams
    }

    func getTeamsUserIsIn(userID: String) async throws -> [Team] {
        // 1. Obtener los equipos donde está el usuario
        let teamsDTOs = try await teamDatasource.getTeamsUserIsIn(userID: userID)
        
        var finalTeams: [Team] = []
        
        for teamDTO in teamsDTOs {
            var members: [AppUser] = []
            
            // 2. Obtener miembros secuencialmente
            for id in teamDTO.membersIDs {
                let userDTO = try await userDatasource.getUserByID(userID: id)
                members.append(userDTO.toAppUser())
            }
            
            // 3. Convertir DTO a modelo App
            let team = teamDTO.toTeam(members: members)
            finalTeams.append(team)
        }
        
        return finalTeams
    }
    
}
