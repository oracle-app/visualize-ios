//
//  VisualizationCard.swift
//  visualize
//
//  Created by Carlos Amador on 14/04/26.
//

import Foundation

struct VisualizationCard: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let authorID: String
    let createdAt: Date
    let configJSON: String
    let teamsSharedWith: [Team]
    let usersSharedWith: [AppUser]
    let allUsersSharedWith: [AppUser]
}
