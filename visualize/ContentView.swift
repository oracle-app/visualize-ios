//
//  ContentView.swift
//  visualize
//
//  Created by Carlos Amador on 11/04/26.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        FeedView(viewModel: .preview, shouldLoad: true)
        //NavBar()
    }
}

#Preview {
    ContentView()
    
}
