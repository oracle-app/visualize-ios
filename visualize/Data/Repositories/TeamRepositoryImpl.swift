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
        let teamsOwnedByUserRaw: [TeamDTO] = try await teamDatasource.getTeamsUserOwns(userID: userID)
        return try await withThrowingTaskGroup(of: Team.self) { teamGroup in
                
                for teamDTO in teamsOwnedByUserRaw {
                    teamGroup.addTask {
                        // 3. Dentro de cada equipo, obtenemos sus usuarios en paralelo
                        let users = try await withThrowingTaskGroup(of: UserDTO.self) { userGroup in
                            for id in teamDTO.membersIDs {
                                userGroup.addTask {
                                    try await self.userDatasource.getUserByID(userID: id)
                                }
                            }
                            
                            var fetchedUsers: [UserDTO] = []
                            for try await user in userGroup {
                                fetchedUsers.append(user)
                            }
                            return fetchedUsers.map { $0.toAppUser() }
                        }
                        
                        // 4. Transformamos el DTO al modelo de dominio ShareTeam
                        return await teamDTO.toTeam(members: users)
                    }
                }
                
                var finalTeams: [Team] = []
                for try await team in teamGroup {
                    finalTeams.append(team)
                }
                return finalTeams
        }
    }
    
    func getTeamsUserIsIn(userID: String) async throws -> [Team] {
    
        let teamsDTOs = try await teamDatasource.getTeamsUserIsIn(userID: userID)
        
        
        return try await withThrowingTaskGroup(of: Team.self) { teamGroup in
            
            for teamDTO in teamsDTOs {
                teamGroup.addTask {
                    
                    let members = try await withThrowingTaskGroup(of: AppUser.self) { userGroup in
                        for id in teamDTO.membersIDs {
                            userGroup.addTask {
                                let userDTO = try await self.userDatasource.getUserByID(userID: userID)
                                
                                return userDTO.toAppUser()
                            }
                        }
                        
                        var fetchedMembers: [AppUser] = []
                        for try await member in userGroup {
                            fetchedMembers.append(member)
                        }
                        return fetchedMembers
                    }
                    
        
                    return await teamDTO.toTeam(members: members)
                }
            }
            
        
            var finalTeams: [Team] = []
            for try await team in teamGroup {
                finalTeams.append(team)
            }
            
            return finalTeams
        }
    }
    
}
