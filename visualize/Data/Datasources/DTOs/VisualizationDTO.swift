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
    let sharedWithGroups: [DocumentReference]
    let sharedWithUsers: [DocumentReference]
    let createdAt: Date
    let authorID: DocumentReference
    let ownerID: DocumentReference
    let configJSON: String
}
