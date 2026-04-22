//
//  LoadedListView.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//


import SwiftUI

struct LoadedListView: View {

    let items: [FeedItem]
    let onShare: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    FeedCard(
                        title: item.title,
                        author: item.author,
                        date: item.date,
                        onShare: onShare
                    )
                }
            }
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }
}
