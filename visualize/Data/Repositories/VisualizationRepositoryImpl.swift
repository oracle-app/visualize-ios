//
//  VisualizationRepositoryImpl.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import Foundation
internal import FirebaseFirestoreInternal

class VisualizationRepositoryImpl: VisualizationRepository {
    let userDatasource = UserDatasource()
    let visualizationDatasource = VisualizationDatasource()

    func getVisualizationsWithFilter(userID: String, visualizationFilter: VisualizationFilter) async throws -> [VisualizationCard] {
        let dtos: [VisualizationDTO]
        switch visualizationFilter {
        case .all:
            let sharedVisualizations = try await visualizationDatasource.getAllSharedVisualizations(userID: userID)
            let personalVisualizations = try await visualizationDatasource.getAllPersonalVisualizations(userID: userID)
            dtos = sharedVisualizations + personalVisualizations
        case .shared:
            dtos = try await visualizationDatasource.getAllSharedVisualizations(userID: userID)
        case .personal:
            dtos = try await visualizationDatasource.getAllPersonalVisualizations(userID: userID)
        }
        
        var visualizationCards: [VisualizationCard] = []
        
        for dto in dtos {
            let author = try await userDatasource.getUser(id: dto.authorID)
            let users = try await visualizationDatasource.getAllUsersVisualizationIsSharedWith(visualizationID: dto.id ?? "")
            let sharedUsers: [AppUser] = users.map {$0.toAppUser()}
            let card = dto.toVisualizationCard(authorName: author.username, sharedUsers: sharedUsers)
            visualizationCards.append(card)
        }
        return visualizationCards
    }
}


// Ubicación: data/repositories/VisualizationRepositoryImpl.swift
//class VisualizationRepositoryImpl: VisualizationRepository {
//    let visualizationDataSource: VisualizationDataSource
//    let userDataSource: UserDataSource // Necesario para obtener nombres y usuarios
//
//    func getVisualizationCard(id: UUID) async -> VisualizationCard {
//        // 1. Obtener el DTO crudo
//        let dto = await visualizationDataSource.fetchVisualization(id: id) [cite: 31]
//        
//        // 2. Resolver la información faltante (IDs -> Nombres/Objetos)
//        // Buscamos el nombre del autor usando el authorID del DTO
//        let authorName = await userDataSource.fetchUserName(id: dto.authorID)
//        
//        // Buscamos los objetos User para cada ID en sharedWithUsers
//        let sharedUsers = await userDataSource.fetchUsers(ids: dto.sharedWithUsers)
//        
//        // 3. Mapear y devolver la entidad limpia al dominio [cite: 29, 37]
//        return dto.toDomain(authorName: authorName, sharedUsers: sharedUsers)
//    }
//}
