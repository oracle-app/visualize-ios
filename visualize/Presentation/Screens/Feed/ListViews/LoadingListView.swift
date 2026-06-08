//
//  LoadingListView.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//

import SwiftUI

struct LoadingListView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonFeedCard()
                }
            }
            .padding(.top, 10)
        }
        .disabled(true)
        .accessibilityIdentifier("loadingListView")
    }
}
