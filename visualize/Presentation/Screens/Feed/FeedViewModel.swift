//
//  FeedViewModel.swift
//  Visualize
//
//  Created by Jorge Flores on 13/04/26.
//
import SwiftUI
import Observation

struct FeedItem: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let date: String
}

@Observable
class FeedViewModel {
    var state: FeedState = .loading
    
    private let service: FeedServiceProtocol

    init(service: FeedServiceProtocol = FeedService()) {
        self.service = service
    }
    
    enum FeedState {
        case loading
        case loaded([FeedItem])
        case empty
        case error
    }

    
 
    
    func loadData() {
        state = .loading
       
        Task {
            do {
                // simulate loading delay
                try await Task.sleep(nanoseconds: 1_000_000_000)
                let items = try await service.fetchFeed()
                state = items.isEmpty ? .empty : .loaded(items)
            } catch {
                state = .error
            }
        }
    }
}
