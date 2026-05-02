//
//  VisualizationCardMapper.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//
import Foundation
internal import FirebaseFirestoreInternal

extension VisualizationDTO {
    func toVisualizationCard(
            authorName: String,
            teamsSharedWith: [Team],
            usersSharedWith: [AppUser]
        ) -> VisualizationCard {
            var allUsersDict: [String: AppUser] = [:]
            for user in usersSharedWith {
                allUsersDict[user.id] = user
            }
            for team in teamsSharedWith {
                for member in team.members {
                    allUsersDict[member.id] = member
                }
            }
            let allUsers = Array(allUsersDict.values)
            return VisualizationCard(
                id: self.id ?? "",
                title: self.title,
                author: authorName,
                createdAt: self.createdAt,
                configJSON: self.configJSON,
                teamsSharedWith: teamsSharedWith,
                usersSharedWith: usersSharedWith,
                allUsersSharedWith: allUsers
            )
        }
}
