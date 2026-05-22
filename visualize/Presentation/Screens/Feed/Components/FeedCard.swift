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
    @State private var chart: ChartData? = nil
    var visualizationID: String
    var previewJSON: String
    var title: String
    var author: String
    var date: Date
    var onShare: () -> Void
    var onTap: () -> Void
    var onHide: () -> Void
    var onDelete: () -> Void
    var sharedWith: [AppUser]? = nil
    var isOwner: Bool = false
    let maxAvatars = 3
    /// TO DO: Image Implementation that uses profilePictureURL
    /// Asigns random color based on ID.
    private var colors: [Color] {
        (sharedWith ?? []).map { user in
            Color.random(from: user.id)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5){
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.primaryText)
                        .minimumScaleFactor(0.5)
                    HStack(spacing: 12) {
                        Text("by \(isOwner ? "me" : author)")
                        Text("•")
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.appTeal)
                }
                Spacer()
                Menu {
                    if isOwner {
                        Button {
                            onShare()
                        } label: {
                            Label("Share", systemImage: "person.badge.plus")
                        }
                        Button(role: .destructive) {
                            showAlert2.toggle()
                        } label: {
                            Label("Delete for everyone", systemImage: "trash")
                        }
                    } else {
                        Button(role: .destructive) {
                            showAlert1.toggle()
                        } label: {
                            Label("Delete for me", systemImage: "trash")
                        }
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 37, height: 37)
                        
                        Image(systemName: "ellipsis")
                            .font(.system(size: 22))
                            .foregroundStyle(AppColors.UI.cardShare)
                    }
                    .frame(width: 37, height: 37)
                    .contentShape(Circle())
                }.buttonStyle(.plain).shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .alert(
                    "Delete for me?",
                    isPresented: $showAlert1
                ) {
                    Button("Delete", role: .destructive) {
                        onHide()
                    }
                    
                    Button("Cancel", role: .cancel) {
                        
                    }
                } message: {
                    Text("This will remove the visualization from your feed. To see it again, the owner will need to share it with you.")
                }
                .alert(
                    "Delete for everyone?",
                    isPresented: $showAlert2
                ) {
                    Button("Delete", role: .destructive) {
                        onDelete()
                    }
                    Button("Cancel", role: .cancel) {
                    }
                } message: {
                    Text("This will permanently remove the visualization from the feed for you and everyone you shared it with. This action cannot be undone.")
                }
            }
            ZStack {
                if let chartData = chart {
                    ChartRendererView(chart: chartData)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .skeletonEffect()
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(minHeight: 200)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 10))
            .task(id: visualizationID) {
                let cacheKey = "\(visualizationID)-\(previewJSON.hash)"
                
                if let cachedChart = ChartCacheManager.shared.getChart(for: cacheKey) {
                    self.chart = cachedChart
                    return
                }
                
                let parsedChart = await Task.detached(priority: .background) {
                    return ChartConfigParser.parse(from: previewJSON) ?? .unsupported(type: "Invalid JSON")
                }.value
                
                ChartCacheManager.shared.saveChart(parsedChart, for: cacheKey)
                
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.3)) {
                        self.chart = parsedChart
                    }
                }
            }
            
            if let sharedWith, !sharedWith.isEmpty {
                HStack(spacing: -20) {
                    let displayMembers = Array(sharedWith.prefix(maxAvatars))
                    let remainingCount = sharedWith.count - displayMembers.count
                    ForEach(Array(displayMembers.enumerated()), id: \.element.id) { index, user in
                        UserAvatarView(user: user, size: 33, showBorder: true)
                            .zIndex(Double(maxAvatars - index))
                    }
                    if remainingCount > 0 {
                        ZStack {
                            Circle().fill(Color(.systemBackground))
                            Text("+\(remainingCount)")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.primaryText)
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
       .contentShape(Rectangle())
               .onTapGesture {
                   onTap()
               }
   }
}
/// Generates a random color based on the given string
extension Color {
    static func random(from string: String) -> Color {
        var hasher = Hasher()
        hasher.combine(string)
        let hash = hasher.finalize()

        let red = Double((hash >> 16) & 0xFF) / 255.0
        let green = Double((hash >> 8) & 0xFF) / 255.0
        let blue = Double(hash & 0xFF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}

#Preview("Con usuarios compartidos") {
    FeedCard(
        visualizationID: "preview-id-1",
        previewJSON: "{}",
        title: "Detailed Breakdown of Revenue, Transaction Volume, and User Engagement Trends Over Time",
        author: "Mariana Islas",
        date: Date(),
        onShare: { print("share tapped") },
        onTap: { print("card tapped") },
        onHide: { print("hide tapped") },
        onDelete: { print("delete tapped") },
        sharedWith: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana"),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis"),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria"),
            AppUser(id: "4", email: "carlos@mail.com", profilePictureURL: nil, username: "Carlos")
        ],
        isOwner: true
    )
}

#Preview("Sin usuarios compartidos") {
    FeedCard(
        visualizationID: "preview-id-2",
        previewJSON: "{}",
        title: "Total Transactions by Category",
        author: "Mariana Islas",
        date: Date(),
        onShare: { print("share tapped") },
        onTap: { print("card tapped") },
        onHide: { print("hide tapped") },
        onDelete: { print("delete tapped") },
        sharedWith: nil,
        isOwner: false
    )
}
 
