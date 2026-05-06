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
    func updateSharedUsers(visualizationID: String, userIDs: [String]) async throws {
        try await visualizationDatasource.updateSharedUsers(
            visualizationID: visualizationID,
            userIDs: userIDs
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
        for i in stride(from: 0, to: ids.count, by: chunkSize) {
            let end = min(i + chunkSize, ids.count)
            let chunk = Array(ids[i..<end])
            let chunkUsers = try await userDatasource.getUsers(byIDs: chunk)
            allUsers.append(contentsOf: chunkUsers)
        }
        return allUsers
    }
    private func fetchTeamsInChunks(ids: [String]) async throws -> [TeamDTO] {
        var allTeams: [TeamDTO] = []
        let chunkSize = 30
        for i in stride(from: 0, to: ids.count, by: chunkSize) {
            let end = min(i + chunkSize, ids.count)
            let chunk = Array(ids[i..<end])
            let chunkTeams = try await teamsDatasource.getTeams(byIDs: chunk)
            allTeams.append(contentsOf: chunkTeams)
        }
        return allTeams
    }
}
