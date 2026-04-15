//
//  VisualizationRepositoryImpl.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import Foundation

class VisualizationRepositoryImpl: VisualizationRepository {
    internal let userDataSource: UserDataSource
    
    init(userDataSource: UserDataSource) {
        self.userDataSource = userDataSource
    }
    
    func getVisualizationsWithFilter(userID: UUID, visualizationFilter: VisualizationFilter) async throws -> [VisualizationCard] {
        
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
