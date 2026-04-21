//
//  LoadingListView.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//

import SwiftUI

struct LoadingListView: View {

    var body: some View {
        VStack(spacing: 15) {
            ProgressView("Loading Visualizations...")
                .font(.body.bold())
                .foregroundStyle(Color.primaryAzul)

            Text("Fetching the latest visualizations for you.")
                .foregroundStyle(.gray)
                .padding(.horizontal, 80)
                .padding(.bottom, 100)
                .multilineTextAlignment(.center)
        }
        .hCenter()
    }
}
