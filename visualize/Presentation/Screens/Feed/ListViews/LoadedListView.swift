//
//  LoadedListView.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//


import SwiftUI

struct LoadedListView: View {

    let cards: [FeedCard]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(cards.indices, id: \.self) { index in
                    cards[index]
                }
            }
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
    }
}
