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
    var currentUserID: String?
    var image: UIImage? = nil

    @Binding var activeCommentID: String?
    @Binding var activeCommentAuthor: String?
    @State private var showDeleteAlert = false
    
    var isReplying: Bool { activeCommentID == comment.id }  // True when this comment is active
    var isAuthor: Bool { currentUserID == comment.authorID }
    
    var onDeleteComment: (String, String) -> Void
    var onDeleteReply: (String, String, String) -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            commentHeader
            contentSection
            imageSection
            ThreadRepliesList(
                threads: comment.threads,
                currentUserID: currentUserID,
                commentID: comment.id,
                onDeleteReply: onDeleteReply
            )
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
            
            UserAvatarView(
                username: comment.authorName ?? "",
                avatarURL: comment.authorAvatarURL,
                size: 30
            )
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isAuthor ? "Me" : (comment.authorName ?? comment.authorID))
                    .font(.body.weight(.bold))
                    .foregroundStyle(Color.primaryText)

                Text(comment.timeAgo)
                    .font(.subheadline)
                    .foregroundStyle(Color.primaryText.opacity(0.5))
            }

            Spacer()
            
            Menu {
                if isAuthor {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeCommentID = comment.id
                            activeCommentAuthor = "Me"
                        }
                    } label: {
                        Label("Reply", systemImage:"arrowshape.turn.up.left")
                    }
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeCommentID = comment.id
                            activeCommentAuthor = comment.authorName ?? comment.authorID
                        }
                    } label: {
                        Label("Reply", systemImage:"arrowshape.turn.up.left")
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 37, height: 37)

                    Image(systemName: "ellipsis")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.appTeal)
                }
                .frame(width: 37, height: 37)
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .alert("Delete thread?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    onDeleteComment(comment.id, comment.authorID)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove the thread and all its replies. This action cannot be undone.")
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
    // ThreadCommentRow.swift

    private var imageSection: some View {
        Group {
            if let urlString = comment.imageURL,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        placeholderImage
                    case .empty:
                        ProgressView()
                            .frame(height: 120)
                    @unknown default:
                        placeholderImage
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black.opacity(0.08))
            .frame(height: 200)
            .overlay(Label("", systemImage: "photo").foregroundStyle(.secondary))
    }
    
    private var contentSection: some View {
        Group {
            if let content = comment.content, !content.isEmpty {
                Text(content)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, comment.threads.isEmpty ? 8 : 0)
            }
        }
    }
}

// MARK: - Thread Replies List

/// Renders the full list of replies, passing `isFirst` to correctly style the connector line.
private struct ThreadRepliesList: View {
    let threads: [ThreadReply]
    let currentUserID: String?
    let commentID: String
    var onDeleteReply: (String, String, String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(threads) { reply in
                ThreadReplyRow(
                    isFirst: isFirst(reply),
                    isLast: isLast(reply),
                    reply: reply,
                    currentUserID: currentUserID,
                    commentID: commentID,
                    onDelete: onDeleteReply
                )
            }
        }
        .padding(.bottom, 12)
    }
    private func isFirst(_ reply: ThreadReply) -> Bool {
        threads.first?.id == reply.id
    }
    
    private func isLast(_ reply: ThreadReply) -> Bool {
        threads.last?.id == reply.id
    }
}

// MARK: - Preview

#Preview {
    ThreadCommentRow(
        comment: Comment(
            id: "c1",
            authorID: "u1",
            authorName: "Kimberly Marquez",
            content: "This is a test comment.",
            imageURL: nil,
            createdAt: Date(),
            threads: []
        ),
        currentUserID: "u1",
        activeCommentID: .constant(nil),
        activeCommentAuthor: .constant(nil),
        onDeleteComment: { _, _ in },
        onDeleteReply: { _, _, _ in }
    )
}
