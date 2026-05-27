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

struct ThreadReplyRow: View {

    // MARK: - Properties
    @State private var showDeleteAlert = false

    var isFirst: Bool = false  // Controls the top connector line height
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
        }
        .padding(.leading, 14)
    }

    // MARK: - Subviews

    /// Vertical line and avatar that visually connects the reply to its parent comment.
    private var threadConnector: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(.white).opacity(0.5))
                .frame(width: 2, height: isFirst ? 16 : 40)

            UserAvatarView(
                username: reply.authorName,
                avatarURL: reply.authorAvatarURL,
                size: 30)
            
            Spacer().frame(minHeight: 12)
        }
        .frame(width: 44)
    }

    /// Bubble containing the author name, timestamp, and reply content.
    private var replyBubble: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(isAuthor ? "Me" : reply.authorName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.black)

                Spacer()

                Text(reply.timeAgo)
                    .font(.system(size: 13))
                    .foregroundStyle(.black.opacity(0.5))
            }
            Text(reply.content)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.black)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appThreadsReply)
        )
        .padding(.trailing, 14)
        .padding(.vertical, 4)
        .contextMenu {
            if isAuthor, let replyID = reply.id {
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
    ThreadReplyRow(
        isFirst: true,
        reply: ThreadReply(
            id: "r1",
            authorID: "u1",
            authorName: "Diana Escalante",
            authorAvatarURL: nil,
            createdAt: Timestamp(date: Date()),
            content: "This is a test reply",
            timeAgo: "5 min ago"
        ),
        currentUserID: "u2",
        commentID: "c1",
        onDelete: { _, _, _ in }
    )
}
