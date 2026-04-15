//
//  a.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

struct LoadVisualizationsUseCase {
    let visualizationRepository: VisualizationRepository
    
    func execute(visualizationFilter: VisualizationFilter) -> [VisualizationCard] {
        return visualizationRepository.getVisualizationsWithFilter(visualizationFilter: visualizationFilter)
    }
    
}
