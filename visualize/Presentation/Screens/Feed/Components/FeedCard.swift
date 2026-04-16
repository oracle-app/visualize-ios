//
//  FeedCard.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 13/04/26.
//

import SwiftUI

struct FeedCard: View {
    @State private var showAlert1 = false
    @State private var showAlert2 = false
    
    var title: String
    var author: String
    var date: String
    
    let letters = Color(red: 52/255, green: 121/255, blue: 124/255, opacity: 1)
    let titleColor =  Color(red: 26/255, green: 47/255, blue: 63/255, opacity: 1)
    let bg = Color(red: 230/255, green: 237/255, blue: 236/255, opacity: 1)
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(titleColor)
                    .minimumScaleFactor(0.5)
                    .frame(height: 50, alignment: .center)
                Spacer()
                Menu {
                    Button {
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
                    Image(systemName: "ellipsis")
                        .font(.system(size: 22))
                        .foregroundStyle(letters)
                        .frame(width: 37, height: 37)
                        .glassEffect()
                }
                
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
            
            HStack(spacing: 25) {
                Text("by \(author)")
                Text("•")
                Text("\(date)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(letters)
            
            Text("viz")
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.white)
                .cornerRadius(10)

            
            HStack(spacing: -20) {
                Circle()
                    .fill(.red)
                    .frame(width: 33, height: 33)
                    .overlay(Circle().stroke(bg, lineWidth: 2))
                    .zIndex(3)
                
                Circle()
                    .fill(.blue)
                    .frame(width: 33, height: 33)
                    .overlay(Circle().stroke(bg, lineWidth: 2))
                    .zIndex(2)
                
                Circle()
                    .fill(.green)
                    .frame(width: 33, height: 33)
                    .overlay(Circle().stroke(bg, lineWidth: 2))
                    .zIndex(1)
                ZStack {
                        Circle()
                        .fill(.white)
                        
                        Text("+2")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color(red: 68/255, green: 68/255, blue: 68/255, opacity: 1))
                    }
                    .frame(width: 33, height: 33)
                    .overlay(Circle().stroke(bg, lineWidth: 2))
                    .padding(.leading, 10)
                    .zIndex(0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
        }
        .padding(16)
        .background(bg)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
        .frame(height: 390)
    }
}

#Preview {
    FeedCard(title: "Detailed Breakdown of Revenue, Transaction Volume, and User Engagement Trends Over Time", author: "Mariana Islas", date: "10 apr 2026")
    
    //FeedCard(title: "Total Transactions by Category", author: "Mariana Islas", date: "10 apr 2026")
    
    //FeedCard(title: "Detailed analysis of the relative performance of major global currencies compared to the US dollar over time, considering their historical evolution, volatility, and the economic factors that influence their behavior in international markets.", author: "Mariana Islas", date: "10 apr 2026")
}

