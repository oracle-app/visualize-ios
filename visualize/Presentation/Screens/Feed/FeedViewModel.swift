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
        case loaded([CardModel])
        case empty
        case error
    }


    
    
    func loadData(){
        state = .loading
        
        
        // simulacion del loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            //Temporal, false devolvera la view de error, true devolvera la view de empty o loaded (dependiendo del prop data)
            let success = true
            
            
            if success {
                
                // prop data
                let cards: [CardModel] = []
                /*let cards = [
                    CardModel(title: "Tarjeta 1", description: "Esta es la Descripcion de la tarjeta 1"),
                    CardModel(title: "Tarjeta 2", description: "Esta es la Descripcion de la tarjeta 2")
                    ]*/
                 
                
                self.state = cards.isEmpty ? .empty : .loaded(cards)
                
            } else{
                self.state = .error
            }
            
        }
    }
}
