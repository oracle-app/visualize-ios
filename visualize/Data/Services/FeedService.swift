//
//  FeedService.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//
import SwiftUI

class FeedService: FeedServiceProtocol {
    func fetchFeed() async throws -> [VisualizationCard] {
        // The API/database call will be here
        
        // prop data:
        
        //let items: [VisualizationCard] = []
        let items = [
            VisualizationCard(
                id: "TESTIDKASLDBweqw",
                title: "Detailed Breakdown of Revenue, Transaction Volume, and User Engagement Trends Over Time",
                author: "Mariana Islas",
                createdAt: Date.now,
                sharedWith: [
                    AppUser(
                        id: "1",
                        email: "Test1@Gmail.com",
                        profilePictureURL: "www.testurl.com/image/1",
                        username: "myusername1"
                    )
                ],
                configJSON: "TESTIDKASLDBF",
            ),
            VisualizationCard(
                id: "TESTIDKASLDBF",
                title: "Total Transactions by Category",
                author: "Mariana Islas",
                createdAt: Date.now,
                sharedWith: [
                    AppUser(
                        id: "2",
                        email: "Test2@Gmail.com",
                        profilePictureURL: "www.testurl.com/image/2",
                        username: "myusername2"
                    )
                ],
                configJSON: "TESTIDKASLDBF",
            ),
            VisualizationCard(
                id: "TESTID34SLDBF",
                title: "Detailed analysis of the relative performance of major global currencies compared to the US dollar over time...",
                author: "Mariana Islas",
                createdAt: Date.now,
                sharedWith: [
                    AppUser(
                        id: "3",
                        email: "Test3@Gmail.com",
                        profilePictureURL: "www.testurl.com/image/3",
                        username: "myusername3"
                    )
                ],
                configJSON: "TESTIDKASLDBF",
            )
        ]
         
         

        return items
    }
}
