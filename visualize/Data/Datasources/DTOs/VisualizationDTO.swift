//
//  VisualizationDTO.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import Foundation
import FirebaseFirestore

struct VisualizationDTO: Codable {
    @DocumentID let id: UUID
    let title: String
    let sharedWithGroups: [String]
    let sharedWithUsers: [String]
    let createdAt: Date
    let authorID: String
    let ownerID: String
    let configJSON: String
}
