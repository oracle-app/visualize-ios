//
//  NavBar.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/15/26.

// Reusable navigation bar component that manages the main app navigation using a tab-based structure.
// It maintains the currently selected tab state and dynamically switches between different views such as feed, create, teams, and profile.
// Integrates system tab bar customization (UIKit appearance) to control icon colors and visual styling independently from the rest of the UI.
// Designed to centralize navigation logic while allowing scalable extension of tabs and consistent user experience across the application.

import SwiftUI
struct NavBar: View {
    @State private var selectedTab: Tabs = .feed
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.stackedLayoutAppearance.selected.iconColor = .systemMint
        appearance.stackedLayoutAppearance.normal.iconColor = .black
        
        
        UITabBar.appearance().standardAppearance =  appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
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
        }
    }
}
#Preview {
    NavBar()
}

