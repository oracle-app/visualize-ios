//
//  FeedService.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//

class FeedService: FeedServiceProtocol {
    func fetchFeed() async throws -> [FeedCard] {
        // The API/database call will be here
        
        // prop data:
        
        //let cards: [FeedCard] = []
        let cards = [
         FeedCard(title: "Detailed Breakdown of Revenue, Transaction Volume, and User Engagement Trends Over Time", author: "Mariana Islas", date: "10 apr 2026"),
         FeedCard(title: "Total Transactions by Category", author: "Mariana Islas", date: "10 apr 2026"),
         FeedCard(title: "Detailed analysis of the relative performance of major global currencies compared to the US dollar over time, considering their historical evolution, volatility, and the economic factors that influence their behavior in international markets.", author: "Mariana Islas", date: "10 apr 2026")
            ]
         
        
        return cards
    }
}
