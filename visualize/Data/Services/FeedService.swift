//
//  FeedService.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//

class FeedService: FeedServiceProtocol {
    func fetchFeed() async throws -> [FeedItem] {
        // The API/database call will be here
        
        // prop data:
        
        //let cards: [FeedCard] = []
        let items = [
            FeedItem(
                title: "Detailed Breakdown of Revenue, Transaction Volume, and User Engagement Trends Over Time",
                author: "Mariana Islas",
                date: "10 apr 2026"
            ),
            FeedItem(
                title: "Total Transactions by Category",
                author: "Mariana Islas",
                date: "10 apr 2026"
            ),
            FeedItem(
                title: "Detailed analysis of the relative performance of major global currencies compared to the US dollar over time...",
                author: "Mariana Islas",
                date: "10 apr 2026"
            )
        ]

        return items
    }
}
