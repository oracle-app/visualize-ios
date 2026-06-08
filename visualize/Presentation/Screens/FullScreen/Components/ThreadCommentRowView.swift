//
//  ThreadCommentRowView.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
///  A SwiftUI View that handles the presentation layout for a master parent comment card.
///
///  Responsibilities:
///  - Renders user metadata context, timestamp indicators, and textual data layers.
///  - Uses AsyncImage phase blocks to safely retrieve structural remote snap snapshots.
///  - Integrates contextual interactive controls for inline responding or secure record removals.
///  - Cascades parent validation privileges down into encapsulated subordinate reply collections.

import SwiftUI
import FirebaseCore

struct ThreadCommentRowView: View {

    // MARK: - Properties
    
    var comment: Comment
    var currentUserID: String?
    var canDelete: (String) -> Bool
    var image: UIImage? = nil

    @Binding var activeCommentID: String?
    @Binding var activeCommentAuthor: String?
    @State private var showDeleteAlert = false
    
    var isReplying: Bool { activeCommentID == comment.id } 
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
                canDelete: canDelete,
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
                Text(comment.createdAt.timeAgoDisplay())
                    .font(.subheadline)
                    .foregroundStyle(Color.primaryText.opacity(0.5))
            }

            Spacer()
            Group {
                if canDelete(comment.authorID) {
                    Menu {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                activeCommentID = comment.id
                                activeCommentAuthor = isAuthor ? "Me" : (comment.authorName ?? comment.authorID)
                            }
                        } label: {
                            Label("Reply", systemImage: "arrowshape.turn.up.left")
                        }
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
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
                } else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeCommentID = comment.id
                            activeCommentAuthor = comment.authorName ?? comment.authorID
                        }
                    } label: {
                        Image(systemName: "arrowshape.turn.up.left")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.appTeal)
                            .frame(width: 37, height: 37)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .buttonStyle(.plain)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
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
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    case .failure:
                        placeholderImage
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity, alignment: .center)
                    @unknown default:
                        placeholderImage
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, (comment.content?.isEmpty ?? true) ? 16 : 8) 
        .padding(.bottom, comment.threads.isEmpty ? 12 : 6)
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.black.opacity(0.08))
            .frame(height: 200)
            .overlay(Label("", systemImage: "photo").foregroundStyle(.secondary))
            .frame(maxWidth: .infinity, alignment: .leading)
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
    
    var canDelete: (String) -> Bool
    
    var onDeleteReply: (String, String, String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(threads) { reply in
                ThreadReplyRowView(
                    isFirst: isFirst(reply),
                    isLast: isLast(reply),
                    reply: reply,
                    currentUserID: currentUserID,
                    commentID: commentID,
                    onDelete: onDeleteReply,
                    canDelete: canDelete(reply.authorID)
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
    ThreadCommentRowView(
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
        canDelete: { _ in true },
        activeCommentID: .constant(nil),
        activeCommentAuthor: .constant(nil),
        onDeleteComment: { _, _ in },
        onDeleteReply: { _, _, _ in }
    )
}
