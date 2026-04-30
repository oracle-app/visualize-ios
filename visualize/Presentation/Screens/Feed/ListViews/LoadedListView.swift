//
//  LoadedListView.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//


import SwiftUI

/// Displays the list of visualization cards when the feed has loaded successfully.
struct LoadedListView: View {

    let items: [VisualizationCard]
    
    /// Called when the user taps Share on a card.
    /// Provides the visualization ID and its current shared users.
    let onShare: (String, [AppUser]) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(items, id: \.id) { item in
                    FeedCard(
                        //id: item.id,
                        title: item.title,
                        author: item.author,
                        date: item.createdAt,
                        onShare: { onShare(item.id, item.sharedWith) },
                        sharedWith: item.sharedWith,
                        //configJSON: item.configJSON
                    )
                }
            }
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }
}
