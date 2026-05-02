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
        return try await fetchDetailsAndMap(dtos: dtos)
    }
    func getPersonalVisualizations(userID:String) async throws -> [VisualizationCard] {
        let dtos = try await visualizationDatasource.getAllPersonalVisualizations(userID: userID)
        return try await fetchDetailsAndMap(dtos: dtos)
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
}
