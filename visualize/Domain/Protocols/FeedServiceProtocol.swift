//
//  FeedServiceProtocol.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//

protocol FeedServiceProtocol {
    func fetchFeed(userID: String) async throws -> [VisualizationCard]
}
