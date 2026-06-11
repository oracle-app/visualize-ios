//
//  LoadedListView.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//

import SwiftUI

/// Displays the list of visualization cards when the feed has loaded successfully.
struct LoadedListView: View {
    let items: [VisualizationCard]
    /// Called when the user taps Share on a card.
    /// Provides the visualization ID, all shared users, editable users, and current team IDs.
    let onShare: (String, [AppUser], [AppUser], [String]) -> Void
    let onTap: (VisualizationCard) -> Void
    let onHide: (String) -> Void
    let onDelete: (String) -> Void
    let currentUserID: String
    let currentUserRole: Role

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(items, id: \.id) { item in
                let permissions = VisualizationPermissions(
                    userRole: currentUserRole,
                    currentUserID: currentUserID,
                    authorID: item.authorID
                )
                FeedCardView(
                    visualizationID: item.id,
                    previewJSON: item.previewJSON,
                    title: item.title,
                    author: item.author,
                    date: item.createdAt,
                    onShare: { onShare(item.id, item.allUsersSharedWith, item.usersSharedWith, item.teamsSharedWith.map { $0.id }) },
                    onTap: { onTap(item) },
                    onHide: { onHide(item.id) },
                    onDelete: { onDelete(item.id) },
                    sharedWith: item.allUsersSharedWith,
                    permissions: permissions,
                    isOwner: item.authorID == currentUserID
                )
            }
        }
        .accessibilityElement()
        .accessibilityIdentifier("loadedListView")
    }
}
