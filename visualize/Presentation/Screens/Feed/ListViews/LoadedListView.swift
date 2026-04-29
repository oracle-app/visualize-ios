//
//  LoadedListView.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//


import SwiftUI

struct LoadedListView: View {

    let items: [VisualizationCard]
    let onShare: ([AppUser]) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(items, id: \.id) { item in
                    FeedCard(
                        //id: item.id,
                        title: item.title,
                        author: item.author,
                        date: item.createdAt,
                        onShare: { onShare(item.sharedWith) },
                        sharedWith: item.sharedWith,
                        //configJSON: item.configJSON
                    )
                }
            }
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }
}
