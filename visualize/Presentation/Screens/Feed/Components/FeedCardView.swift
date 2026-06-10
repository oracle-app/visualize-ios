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

struct FeedCardView: View {
    @State private var showAlert1 = false
    @State private var showAlert2 = false
    @State private var chart: ChartData?
    var visualizationID: String
    var previewJSON: String
    var title: String
    var author: String
    var date: Date
    var onShare: () -> Void
    var onTap: () -> Void
    var onHide: () -> Void
    var onDelete: () -> Void
    var sharedWith: [AppUser]?
    var permissions: VisualizationPermissions
    var isOwner: Bool = false
    let maxAvatars = 3
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.Text.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                    HStack(spacing: 12) {
                        Text(String(localized: "by \(isOwner ? "me" : author)"))
                        Text("•")
                        Text(date.timeAgoDisplay())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(AppColors.Brand.teal)
                }
                Spacer()
                Menu {
                    if permissions.canShare {
                        Button {
                            onShare()
                        } label: {
                            Label("Share", systemImage: "person.badge.plus")
                        }
                    }
                    
                    if permissions.canHide {
                        Button(role: .destructive) {
                            showAlert1.toggle()
                        } label: {
                            Label("Delete for me", systemImage: "eye.slash")
                        }
                    }
                    
                    if permissions.canDelete {
                        Button(role: .destructive) {
                            showAlert2.toggle()
                        } label: {
                            Label("Delete for everyone", systemImage: "trash")
                        }
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 37, height: 37)
                        
                        Image(systemName: "ellipsis")
                            .font(.system(size: 22))
                            .foregroundStyle(AppColors.UI.card)
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
                    ChartRendererView(chart: chartData, isFeedCard: true)
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
                StackedAvatarsView(members: sharedWith, maxAvatars: maxAvatars, avatarSize: 33)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
            }
       }
       .padding(16)
       .background(AppColors.Brand.mint)
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

#Preview("Con usuarios compartidos") {
    FeedCardView(
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
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana", role: .admin),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis", role: .admin),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria", role: .admin),
            AppUser(id: "4", email: "carlos@mail.com", profilePictureURL: nil, username: "Carlos", role: .admin)
        ],
        permissions: VisualizationPermissions(userRole: .admin, currentUserID: "1", authorID: "1"),
        isOwner: true
    )
}

#Preview("Sin usuarios compartidos") {
    FeedCardView(
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
        permissions: VisualizationPermissions(userRole: .admin, currentUserID: "1", authorID: "1"),
        isOwner: false
    )
}
