//
//  LoadedListView.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//


import SwiftUI

struct LoadedListView: View {

    let items: [VisualizationCard]
    let onShare: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    FeedCard(
                        //id: item.id,
                        title: item.title,
                        author: item.author,
                        date: "Temporary MANUAL Value",
                        onShare: onShare,
                        //sharedWith: item.sharedWith,
                        sharedWith: [.blue, .red]
                        //configJSON: item.configJSON
                    )
                }
            }
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }
}
