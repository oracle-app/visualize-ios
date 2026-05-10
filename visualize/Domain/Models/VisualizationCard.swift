//
//  VisualizationCard.swift
//  visualize
//
//  Created by Carlos Amador on 14/04/26.
//

import Foundation

struct VisualizationCard: Identifiable, Hashable, Equatable{
    let id: String
    let title: String
    let author: String
    let authorID: String
    let createdAt: Da≈
    let chart: ChartData
    let chartType: ChartType
    let teamsSharedWith: [Team]
    let usersSharedWith: [AppUser]
    let allUsersSharedWith: [AppUser]
}
