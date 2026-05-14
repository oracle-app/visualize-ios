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

    var isFirst: Bool = false  // Controls the top connector line height
    var reply: ThreadReply

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

            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.black)
                .padding(.horizontal)

            Spacer().frame(minHeight: 12)
        }
        .frame(width: 44)
    }

    /// Bubble containing the author name, timestamp, and reply content.
    private var replyBubble: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(reply.authorName)
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
    }
}

// MARK: - Preview

#Preview {
    ThreadReplyRow(
        isFirst: true,
        reply: ThreadReply(
            id: nil,
            authorID: "123",
            authorName: "Diana Escalante",
            authorAvatarURL: "",
            createdAt: Timestamp(date: Date()),
            content: "Este es un reply de prueba",
            timeAgo: "5 min ago"
        )
    )
}
