//
//  VisualizationRepositoryImpl.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import Foundation
internal import FirebaseFirestoreInternal

class VisualizationRepositoryImpl: VisualizationRepository {
    private let userDatasource: UserDatasource
    private let visualizationDatasource: VisualizationDatasource
    private let teamsDatasource: TeamDatasource
    init(userDatasource: UserDatasource,
         visualizationDatasource: VisualizationDatasource,
         teamsDatasource: TeamDatasource) {
        self.userDatasource = userDatasource
        self.visualizationDatasource = visualizationDatasource
        self.teamsDatasource = teamsDatasource
    }
    func updateSharing(visualizationID: String, userIDs: [String], teamIDs: [String]) async throws {
        try await visualizationDatasource.updateSharing(
            visualizationID: visualizationID,
            userIDs: userIDs,
            teamIDs: teamIDs
        )
    }
    func getSharedVisualizations(userID: String) async throws -> [VisualizationCard] {
        let dtos = try await visualizationDatasource.getAllSharedVisualizations(userID: userID)
        return try await fetchDetailsAndMapBatch(dtos: dtos, userID: userID)
    }
    func getPersonalVisualizations(userID: String) async throws -> [VisualizationCard] {
        let dtos = try await visualizationDatasource.getAllPersonalVisualizations(userID: userID)
        return try await fetchDetailsAndMapBatch(dtos: dtos, userID: userID)
    }
    
    private func fetchDetailsAndMap(dtos: [VisualizationDTO]) async throws -> [VisualizationCard] {
        var cards: [VisualizationCard] = []
        for dto in dtos {
            let authorDTO = try await userDatasource.getUserByID(userID: dto.authorID)
            let authorName = authorDTO.username
            let usersDTOs = try await userDatasource.getUsers(byIDs: dto.sharedWithUsers)
            let usersSharedWith: [AppUser] = usersDTOs.map {$0.toAppUser()}
            let teamsDTOs = try await teamsDatasource.getTeams(byIDs: dto.sharedWithTeams)
            let uniqueMemberIDs = Array(Set(teamsDTOs.flatMap(\.membersIDs)))
            let membersDTOs = try await userDatasource.getUsers(byIDs: uniqueMemberIDs)
            let allMembers = membersDTOs.map { $0.toAppUser() }
            let teamsSharedWith: [Team] = teamsDTOs.map { teamDTO in
                let specificTeamMembers = allMembers.filter { member in
                    teamDTO.membersIDs.contains(member.id)
                }
                return teamDTO.toTeam(members: specificTeamMembers)
            }
            let card = dto.toVisualizationCard(
                authorName: authorName,
                teamsSharedWith: teamsSharedWith,
                usersSharedWith: usersSharedWith,
            )
            cards.append(card)
        }
        return cards
    }
    private func fetchDetailsAndMapBatch(dtos: [VisualizationDTO], userID: String) async throws -> [VisualizationCard] {
        guard !dtos.isEmpty else { return [] }
        let currentUser = try await userDatasource.getUserByID(userID: userID)
        let hiddenIDs = Set(currentUser.hiddenVisualizations)
        let visibleDTOs = dtos.filter { dto in
            guard let id = dto.id else { return false }
            return !hiddenIDs.contains(id)
        }
        
        guard !visibleDTOs.isEmpty else { return [] }
        let authorIDs = Set(visibleDTOs.map { $0.authorID })
        let sharedUserIDs = Set(visibleDTOs.flatMap { $0.sharedWithUsers })
        let allUserIDsToFetch = Array(authorIDs.union(sharedUserIDs))
        let sharedTeamIDs = Array(Set(visibleDTOs.flatMap { $0.sharedWithTeams }))
        async let usersFetch = fetchUsersInChunks(ids: allUserIDsToFetch)
        async let teamsFetch = fetchTeamsInChunks(ids: sharedTeamIDs)
        let (usersDTOs, teamsDTOs) = try await (usersFetch, teamsFetch)
        var usersDict = Dictionary(uniqueKeysWithValues: usersDTOs.map { ($0.id, $0) })
        let teamsDict = Dictionary(uniqueKeysWithValues: teamsDTOs.map { ($0.id, $0) })
        let teamMemberIDs = Set(teamsDTOs.flatMap { $0.membersIDs })
        let missingUserIDs = Array(teamMemberIDs.filter { usersDict[$0] == nil })
        if !missingUserIDs.isEmpty {
            let missingUsers = try await fetchUsersInChunks(ids: missingUserIDs)
            for user in missingUsers { usersDict[user.id] = user }
        }
        return visibleDTOs.map { dto in
            let authorName = usersDict[dto.authorID]?.username ?? "Unknown"
            let usersSharedWith = dto.sharedWithUsers.compactMap { usersDict[$0]?.toAppUser() }
            let teamsSharedWith: [Team] = dto.sharedWithTeams.compactMap { teamID in
                guard let teamDTO = teamsDict[teamID] else { return nil }
                let specificTeamMembers = teamDTO.membersIDs.compactMap { usersDict[$0]?.toAppUser() }
                return teamDTO.toTeam(members: specificTeamMembers)
            }
            return dto.toVisualizationCard(
                authorName: authorName,
                teamsSharedWith: teamsSharedWith,
                usersSharedWith: usersSharedWith
            )
        }
    }
    private func fetchUsersInChunks(ids: [String]) async throws -> [UserDTO] {
        var allUsers: [UserDTO] = []
        let chunkSize = 30
        for index in stride(from: 0, to: ids.count, by: chunkSize) {
            let end = min(index + chunkSize, ids.count)
            let chunk = Array(ids[index..<end])
            let chunkUsers = try await userDatasource.getUsers(byIDs: chunk)
            allUsers.append(contentsOf: chunkUsers)
        }
        return allUsers
    }
    private func fetchTeamsInChunks(ids: [String]) async throws -> [TeamDTO] {
        var allTeams: [TeamDTO] = []
        let chunkSize = 30
        for index in stride(from: 0, to: ids.count, by: chunkSize) {
            let end = min(index + chunkSize, ids.count)
            let chunk = Array(ids[index..<end])
            let chunkTeams = try await teamsDatasource.getTeams(byIDs: chunk)
            allTeams.append(contentsOf: chunkTeams)
        }
        return allTeams
    }
    
    func searchVisualizations(userID: String, query: String) async throws -> [VisualizationCard] {
        let dtos = try await visualizationDatasource.searchVisualizations(userID: userID, query: query)
        return try await fetchDetailsAndMap(dtos: dtos)
    }
    
    func deleteVisualization(visualizationID: String) async throws {
        try await visualizationDatasource.deleteVisualization(visualizationID: visualizationID)
    }
    
    func removeUserFromSharedWith(visualizationID: String, userID: String) async throws {
        try await visualizationDatasource.removeUserFromSharedWith(
            visualizationID: visualizationID,
            userID: userID
        )
    }
    
    /// Delegates visualization creation to the datasource with config and preview JSON.
    func createVisualization(
        title: String,
        authorID: String,
        configJSON: String,
        previewJSON: String,
        userIDs: [String],
        teamIDs: [String]
    ) async throws {
        try await visualizationDatasource.createVisualization(
            title: title,
            authorID: authorID,
            configJSON: configJSON,
            previewJSON: previewJSON,
            userIDs: userIDs,
            teamIDs: teamIDs
        )
    }
 
    /// Delegates configJSON fetch to the datasource.
    func fetchConfigJSON(visualizationID: String) async throws -> String? {
        try await visualizationDatasource.fetchConfigJSON(visualizationID: visualizationID)
    }
}
