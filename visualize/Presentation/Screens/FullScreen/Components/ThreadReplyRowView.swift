//
//  ThreadReplyRow.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
//  Displays a single reply within a comment thread.
//  - Shows the author name, relative timestamp, and reply content
//  - Renders a vertical connector line linking replies to their parent comment
//  - Adjusts the connector height based on whether it's the first reply

import SwiftUI
import FirebaseFirestore

struct ThreadReplyRowView: View {

    // MARK: - Properties
    @State private var showDeleteAlert = false

    var isFirst: Bool = false  // Controls the top connector line height
    var isLast: Bool = false
    var reply: ThreadReply
    var currentUserID: String?
    var commentID: String
    var onDelete: (String, String, String) -> Void
    
    var isAuthor: Bool { currentUserID == reply.authorID }

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
                    .foregroundStyle(Color.primaryText)

                Spacer()

                Text(reply.timeAgo)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.primaryText.opacity(0.5))
            }
            Text(reply.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appBackground)
                .shadow(color: Color.primaryText.opacity(0.20), radius: 6, x: 3, y: 5)
        )
        .padding(.trailing, 14)
        .padding(.vertical, 4)
        .contextMenu {
            if isAuthor, reply.id != nil {
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
            Text("This will permanently remove your reply. This action cannot be undone.")
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
            timeAgo: "5m"
        ),
        currentUserID: "u2",
        commentID: "c1",
        onDelete: { _, _, _ in }
    )
}
