//
//  FeedViewModel.swift
//  Visualize
//
//  Created by Jorge Flores on 13/04/26.
//

//  This file contains the ViewModel responsible for managing the presentation logic
//  of the application's main feed. It handles fetching data from the associated service,
//  managing the different UI states (loading, loaded, empty, and error), and exposing
//  them to the view layer so the UI can reactively update.
//
//  It uses the @Observable macro to enable automatic SwiftUI updates without the need
//  for @Published, and defines a FeedItem struct as the basic model representing
//  each item displayed in the feed.
//

import SwiftUI
import Observation


@Observable
class FeedViewModel {
    var state: FeedState = .loading
    
    private let service: FeedServiceProtocol

    init(service: FeedServiceProtocol) {
            self.service = service
    }
    
    enum FeedState {
        case loading
        case loaded([VisualizationCard])
        case empty
        case error
    }

    
 
    
    func loadData() {
        state = .loading
       
        Task {
            do {
                // simulate loading delay
                try await Task.sleep(nanoseconds: 1_000_000_000)
                let items = try await service.fetchFeed(userID: "NQ5fdkRdISA8U7DgcII1")
                for item in items {
                    print(item.id)
                }
                state = items.isEmpty ? .empty : .loaded(items)
            } catch {
                state = .error
            }
        }
    }
}
