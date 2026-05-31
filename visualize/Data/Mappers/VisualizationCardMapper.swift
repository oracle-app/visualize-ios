//
//  VisualizationCardMapper.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//
import Foundation

extension VisualizationDTO {
    func toVisualizationCard(
            authorName: String,
            teamsSharedWith: [Team],
            usersSharedWith: [AppUser],
            preParsedChart: ChartData? = nil
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
            let allUsers = Array(allUsersDict.values).sorted {$0.username < $1.username}
            
            return VisualizationCard(
                id: self.id ?? "",
                title: self.title,
                author: authorName,
                authorID: self.authorID,
                createdAt: self.createdAt,
                previewJSON: self.previewJSON,
                teamsSharedWith: teamsSharedWith,
                usersSharedWith: usersSharedWith,
                allUsersSharedWith: allUsers
            )
        }
    }
     
