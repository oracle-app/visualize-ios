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
            let allUsers = Array(allUsersDict.values)
            
            // Parse preview chart from previewJSON (reduced data) for feed card rendering.
            // FullScreenView parses configJSON directly to get all data points.
            let previewString = self.previewJSON
            let parsedChart = preParsedChart ?? ChartConfigParser.parse(from: previewString) ?? .unsupported(type: "Invalid JSON")
     
            let derivedChartType: ChartType
            switch parsedChart {
            case .verticalBar:   derivedChartType = .verticalBar
            case .horizontalBar: derivedChartType = .horizontalBar
            case .stackedBar:    derivedChartType = .stackedBar
            case .line:          derivedChartType = .line
            case .pie:           derivedChartType = .pie
            case .donut:         derivedChartType = .donut
            case .scatter:       derivedChartType = .scatter
            case .area:          derivedChartType = .area
            case .tile:          derivedChartType = .tile
            case .unsupported:   derivedChartType = .tile
            }
     
            return VisualizationCard(
                id: self.id ?? "",
                title: self.title,
                author: authorName,
                authorID: self.authorID,
                createdAt: self.createdAt,
                chart: parsedChart,
                chartType: derivedChartType,
                teamsSharedWith: teamsSharedWith,
                usersSharedWith: usersSharedWith,
                allUsersSharedWith: allUsers
            )
        }
    }
     
