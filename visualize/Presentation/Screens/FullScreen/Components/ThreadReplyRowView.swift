//
//  ThreadReplyRow.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
///  A SwiftUI View that renders an individual reply card within a nested thread tree.
///
///  Responsibilities:
///  - Displays user profile data, contextual timestamps, and the textual content of a reply.
///  - Draws conditional connector lines depending on the cell's index position inside the thread collection.
///  - Offers an interactive contextual menu with secure access paths for content deletion rules.
///  - Triggers a safety confirmation alert modal prior to execution of structural delete block tasks.

import SwiftUI
import FirebaseFirestore

struct ThreadReplyRowView: View {
    
    // MARK: - Properties
    @State private var showDeleteAlert = false
    /// A conditional layout modifier that alters the height configuration of the top thread connector path.
    
    var isFirst: Bool = false
    /// A conditional indicator that stops rendering the lower structural line segment if this cell node is the ultimate thread element.
    var isLast: Bool = false
    /// The data entity model structure carrying the payload contents of the individual reply node.
    var reply: ThreadReply
    /// The identifier reference string of the authenticated user currently interacting with the system view.
    var currentUserID: String?
    /// The relational master identifier link indicating which parent comment node encapsulates this reply thread tracking timeline.
    var commentID: String
    /// The asynchronous completion handle block executed when an asset structural removal task is confirmed by the system user.
    /// Passes back explicit indices: (commentID, replyID, authorID)
    var onDelete: (String, String, String) -> Void
    /// Evaluates whether the currently logged-in account identity matches the origin author account reference metadata of this reply segment.
    var isAuthor: Bool { currentUserID == reply.authorID }
    /// Structural authorization context state indicating if the active viewer owns privileges sufficient to perform destructive operations on this element.
    var canDelete: Bool

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            threadConnector
            replyBubble
                .padding(.top, 8)
        }
        .padding(.leading, 14)
    }

    // MARK: - Subviews

    /// Vertical line and avatar that visually connects the reply to its parent comment.
    private var threadConnector: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.appBackground.opacity(0.5))
                .frame(width: 2, height: isFirst ? 16 : 20)

            UserAvatarView(
                username: reply.authorName,
                avatarURL: reply.authorAvatarURL,
                size: 30
            )
            
            if !isLast {
                Rectangle()
                    .fill(Color.appBackground.opacity(0.5))
                    .frame(width: 2)
                    .frame(minHeight: 20)
                    .frame(maxWidth: .infinity)
            } else {
                Spacer().frame(minHeight: 12)
            }
        }
        .frame(width: 44)
    }

    /// Bubble containing the author name, timestamp, and reply content.
    private var replyBubble: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(isAuthor ? "Me" : reply.authorName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppColors.Text.primary)

                Spacer()

                Text(reply.createdAt.timeAgoShort())
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.Text.primary.opacity(0.5))
            }
            Text(reply.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(AppColors.Text.primary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appBackground)
                .shadow(color: AppColors.Text.primary.opacity(0.20), radius: 6, x: 3, y: 5)
        )
        .padding(.trailing, 14)
        .padding(.vertical, 4)
        .contextMenu {
            if canDelete, reply.id != nil {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .alert("Delete reply?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let replyID = reply.id {
                    onDelete(commentID, replyID, reply.authorID)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove the reply. This action cannot be undone.")
        }
    }
}

// MARK: - Preview

#Preview {
    ThreadReplyRowView(
        isFirst: false,
        isLast: true,
        reply: ThreadReply(
            id: "r1",
            authorID: "u1",
            authorName: "Diana Escalante",
            authorAvatarURL: nil,
            createdAt: Date(),
            content: "This is a test reply",
        ),
        currentUserID: "u2",
        commentID: "c1",
        onDelete: { _, _, _ in },
        canDelete: true
    )
}
