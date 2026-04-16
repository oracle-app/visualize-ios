//
//  NavBar.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/15/26.

import SwiftUI

struct NavBar: View {
    @State private var selectedTab: Tabs = .feed
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(viewModel: FeedViewModel())
                .tabItem{
                    Label("", systemImage: "house")
                }
                .tag(Tabs.feed)
            CreateVisualization()
                .tabItem{
                    Label("", systemImage: "plus")
                }
                .tag(Tabs.create)
            //TeamsView()
            Color.green.ignoresSafeArea()
                    .tabItem{
                    Label("", systemImage: "person.2")
                }
                .tag(Tabs.teams)
            //ProfileView()
            Color.blue.ignoresSafeArea()
                    .tabItem{
                    Label("",systemImage: "person.circle")
                }
                .tag(Tabs.profile)
            
        }.tint(Color.appTeal)
    }
}

#Preview {
    NavBar()
}
