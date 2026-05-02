//
//  VisualizationDTO.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import Foundation
import FirebaseFirestore

struct VisualizationDTO: Codable {
    @DocumentID var id: String?
    let title: String
    let sharedWithTeams: [String]
    let sharedWithUsers: [String]
    let createdAt: Date
    let authorID: String
    let configJSON: String
    // Should add authorName for faster results
}
