//
//  FeedViewModel.swift
//  Visualize
//
//  Created by Jorge Flores on 13/04/26.
//
import SwiftUI
internal import Combine



class FeedViewModel: ObservableObject {
    @Published var state: FeedState = .loading
    
    enum FeedState {
        case loading
        case loaded([FeedCard])
        case empty
        case error
    }


    
    
    func loadData(){
        state = .loading
        
        
        // simulacion del loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            //Temporal, false devolvera la view de error, true devolvera la view de empty o loaded (dependiendo del prop data)
            let success = true
            
            
            if success {
                
                // prop data
                //let cards: [FeedCard] = []
                let cards = [
                 FeedCard(title: "Detailed Breakdown of Revenue, Transaction Volume, and User Engagement Trends Over Time", author: "Mariana Islas", date: "10 apr 2026"),
                 FeedCard(title: "Total Transactions by Category", author: "Mariana Islas", date: "10 apr 2026"),
                 FeedCard(title: "Detailed analysis of the relative performance of major global currencies compared to the US dollar over time, considering their historical evolution, volatility, and the economic factors that influence their behavior in international markets.", author: "Mariana Islas", date: "10 apr 2026")
                    ]
                 
                
                self.state = cards.isEmpty ? .empty : .loaded(cards)
                
            } else{
                self.state = .error
            }
            
        }
    }
}
