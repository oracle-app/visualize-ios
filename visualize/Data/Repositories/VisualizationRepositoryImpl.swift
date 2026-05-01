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
    init(userDatasource: UserDatasource, visualizationDatasource: VisualizationDatasource) {
        self.userDatasource = userDatasource
        self.visualizationDatasource = visualizationDatasource
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
                let author = try await userDatasource.getUserByID(userID: dto.authorID)
                let sharedUsersDTOs = try await visualizationDatasource.getAllUsersVisualizationIsSharedWith(visualizationID: dto.id ?? "")
                
                let sharedUsers: [AppUser] = sharedUsersDTOs.map { $0.toAppUser() }
                let card = dto.toVisualizationCard(authorName: author.username, sharedUsers: sharedUsers)
                cards.append(card)
            }
            return cards
        }
}
