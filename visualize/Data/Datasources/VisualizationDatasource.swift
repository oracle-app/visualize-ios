//
//  VisualizationDatasource.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import FirebaseFirestore

class VisualizationDatasource {
    private let database = Firestore.firestore()
    
    func getAllPersonalVisualizations(userID: UUID) async throws -> [VisualizationDTO] {
        let snapshot = try await database.collection("visualizations")
                .whereField("ownerID", isEqualTo: "/users/\(userID)")
                .getDocuments()
        let dtos = snapshot.documents.compactMap { document in
                    try? document.data(as: VisualizationDTO.self)
            }
        return dtos
    }
}
