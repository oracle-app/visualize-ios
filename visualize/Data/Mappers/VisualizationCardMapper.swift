//
//  VisualizationCardMapper.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//
import Foundation
internal import FirebaseFirestoreInternal

extension VisualizationDTO{
    func toVisualizationCard(authorName: String, sharedUsers:[AppUser]) -> VisualizationCard {
        return VisualizationCard(
            id: self.id.flatMap {UUID(uuidString: $0)} ?? UUID (),
            title: self.title,
            author: authorName,
            createdAt: self.createdAt,
            sharedWith: sharedUsers,
            configJSON: self.configJSON
        )
    }
}
