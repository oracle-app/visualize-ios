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
        guard let id = self.id else { fatalError("VisualizationDTO must have an id") }
        return VisualizationCard(
            id: id,
            title: self.title,
            author: authorName,
            createdAt: self.createdAt,
            sharedWith: sharedUsers,
            configJSON: self.configJSON
        )
    }
}
