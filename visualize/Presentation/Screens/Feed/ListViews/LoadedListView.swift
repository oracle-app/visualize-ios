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
    /// Provides the visualization ID, all shared users, editable users, and current team IDs.
    let onShare: (String, [AppUser], [AppUser], [String]) -> Void
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(items, id: \.id) { item in
                    FeedCard(
                        title: item.title,
                        author: item.author,
                        date: item.createdAt,
                        onShare: { onShare(item.id, item.allUsersSharedWith, item.usersSharedWith, item.teamsSharedWith.map { $0.id }) },
                        sharedWith: item.allUsersSharedWith,
                    )
                }
            }
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }
}
