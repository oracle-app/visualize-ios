//
//  VisualizationCardMapper.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

extension VisualizationDTO{
    func toVisualizationCard(authorName: String, sharedUsers:[User]) -> VisualizationCard {
        return VisualizationCard(
            id: self.id,
            title: self.title,
            author: authorName,
            createdAt: self.createdAt,
            sharedWith: sharedUsers,
            configJSON: self.configJSON
        )
    }
}
