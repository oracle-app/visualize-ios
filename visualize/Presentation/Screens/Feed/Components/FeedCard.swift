//
//  FeedCard.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 13/04/26.
//
// Reusable feed card component that displays a visualization entry with title, author, and date information.
// It manages local UI state for delete confirmation alerts and handles a contextual menu with actions such as sharing and deleting.
// Integrates interaction callbacks through closures to delegate actions like sharing to parent views.
//

import SwiftUI

struct FeedCard: View {
    @State private var showAlert1 = false
    @State private var showAlert2 = false
    var title: String
    var author: String
    var date: Date
    var onShare: () -> Void
    var sharedWith: [AppUser]
    let maxAvatars = 3
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5){
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.primaryText)
                        .minimumScaleFactor(0.5)
                        //.frame(height: 50, alignment: .center)
                    HStack(spacing: 12) {
                        Text("by \(author)")
                        Text("•")
                        Text("\(date.formatted(date: .complete, time: .omitted))")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.appTeal)
                }
                Spacer()
                Menu {
                    Button {
                        onShare()
                    } label: {
                        Label("Share", systemImage: "person.badge.plus")
                    }
                    Button (role: .destructive) {
                        showAlert2.toggle()
                    } label: {
                        Label("Delete for everyone", systemImage: "trash")
                    }
                    
                    Button (role: .destructive) {
                        showAlert1.toggle()
                    } label: {
                        Label("Delete for me", systemImage: "trash")
                    }
                    
                } label: {
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 37, height: 37)
                        
                        Image(systemName: "ellipsis")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.appTeal)
                    }
                    .frame(width: 37, height: 37)
                    .contentShape(Circle())
                }.buttonStyle(.plain).shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .alert(
                    "Delete visualization?",
                    isPresented: $showAlert2
                ) {
                    Button("Delete", role: .destructive) {
                        
                    }
                    
                    Button("Cancel", role: .cancel) {
                        
                    }
                } message: {
                    Text("This will remove the visualization from your feed. To see it again, the owner will need to share it with you.")
                }
                .alert(
                    "Delete visualization?",
                    isPresented: $showAlert1
                ) {
                    Button("Delete", role: .destructive) {
                        
                    }
                    
                    Button("Cancel", role: .cancel) {
                        
                    }
                } message: {
                    Text("This will permanently remove the visualization from the feed for you and everyone you shared it with. This action cannot be undone.")
                }
            }
            Text("viz")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(10)
            if !sharedWith.isEmpty {
                HStack(spacing: -20) {
                    let displayMembers = Array(sharedWith.prefix(maxAvatars))
                    let remainingCount = sharedWith.count - displayMembers.count
                    ForEach(Array(displayMembers.enumerated()), id: \.element.id) { index, user in
                        UserAvatarView(user: user, size: 33, showBorder: true)
                            .zIndex(Double(maxAvatars - index))
                    }
                    if remainingCount > 0 {
                        ZStack {
                            Circle().fill(.white)
                            Text("+\(remainingCount)")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color(red: 68/255, green: 68/255, blue: 68/255, opacity: 1))
                        }
                        .frame(width: 33, height: 33)
                        .overlay(Circle().stroke(Color.appMint, lineWidth: 2))
                        .padding(.leading, 10)
                        .zIndex(0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
            }
       }
       .padding(16)
       .background(Color.appMint)
       .cornerRadius(10)
       .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
       .padding(.horizontal, 20)
       .frame(height: 390)
       .padding(.bottom, 16)
   }
}

/*
 
 #Preview {
 FeedCard(
 title: "Detailed Breakdown of Revenue, Transaction Volume, and User Engagement Trends Over Time",
 author: "Mariana Islas",
 date: "10 apr 2026",
 onShare: {},
 sharedWith: [.red, .blue, .green, .orange, .purple]
 )
 
 FeedCard(
 title: "Total Transactions by Category",
 author: "Mariana Islas",
 date: "10 apr 2026",
 onShare: {},
 sharedWith: nil
 )
 }
 
 
 */
