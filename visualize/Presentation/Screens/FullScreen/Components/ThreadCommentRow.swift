//
//  ThreadCommentRow.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
//  Displays a single comment card with its image and nested replies.
//  - Shows the author avatar, name, and timestamp in a header
//  - Renders the associated visualization image or a placeholder
//  - Lists all thread replies below the image
//  - Toggles the reply input bar when the reply button is tapped

import SwiftUI
import FirebaseCore

struct ThreadCommentRow: View {

    // MARK: - Properties

    var comment: Comment
    var image: UIImage? = nil

    @Binding var activeCommentID: String?
    var isReplying: Bool { activeCommentID == comment.id }  // True when this comment is active

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            commentHeader
            imageSection
            ThreadRepliesList(threads: comment.threads)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appThreadsPrimary.opacity(0.5))
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Subviews

    /// Author avatar, name, timestamp, and reply toggle button.
    private var commentHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.white)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 2) {
                Text(comment.authorID)
                    .font(.body.weight(.bold))
                    .foregroundStyle(.black)

                Text("20 min ago")
                    .font(.subheadline)
                    .foregroundStyle(.black.opacity(0.5))
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    activeCommentID = isReplying ? nil : comment.id
                }
            } label: {
                Image(systemName: "arrowshape.turn.up.left")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 18)
        }
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                .fill(Color.appThreadsPrimary.opacity(0.5))
        )
    }

    /// Visualization image or a placeholder if no image is provided.
    private var imageSection: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.08))
                    .frame(height: 120)
                    .overlay(
                        Label("", systemImage: "photo")
                            .foregroundStyle(.secondary)
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
    }
}

// MARK: - Thread Replies List

/// Renders the full list of replies, passing `isFirst` to correctly style the connector line.
private struct ThreadRepliesList: View {
    let threads: [ThreadReply]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(threads) { (reply: ThreadReply) in
                ThreadReplyRow(
                    isFirst: isFirst(reply),
                    reply: reply
                )
            }
        }
    }

    private func isFirst(_ reply: ThreadReply) -> Bool {
        threads.first?.id == reply.id
    }
}

// MARK: - Preview

#Preview {
    ThreadCommentRow(
        comment: Comment(
            authorID: "Kimberly Marquez",
            content: "Este es un comentario de prueba",
            createdAt: Timestamp(date: Date())
        ),
        activeCommentID: .constant(nil)
    )
}
