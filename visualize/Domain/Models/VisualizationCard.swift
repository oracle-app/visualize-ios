//
//  VisualizationCard.swift
//  visualize
//
//  Created by Carlos Amador on 14/04/26.
//

import Foundation

struct VisualizationCard: Identifiable {
    let id: String
    let title: String
    let author: String
    let createdAt: Date
    let sharedWith: [AppUser]
    let configJSON: String
}
