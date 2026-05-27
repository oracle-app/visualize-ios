//
//  ThreadsView.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
//  Displays the list of comment threads for a given visualization.
//  - Shows all comments and their nested replies
//  - Handles reply input with an animated bottom bar
//  - Collapses the reply field when the user cancels or submits
//  - Fetches the current Firebase user to author replies

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ThreadsView: View {

    // MARK: - Properties

    let visualizationID: String
    var isCollapsed: Bool = false
    
    @State private var viewModel: ThreadsViewModel
    @State private var replyText = ""
    @State private var activeCommentID: String? = nil
    @State private var activeCommentAuthor: String? = nil
    @State private var currentUser: AppUser? = nil
    
    @FocusState private var isInputFocused: Bool

    // MARK: - Init

    init(visualizationID: String = "3nlO5I3PoEWAaKzwfcKB", isCollapsed: Bool = false) {
        self.visualizationID = visualizationID
        self.isCollapsed = isCollapsed
        self._viewModel = State(initialValue: ThreadsViewModel(visualizationID: visualizationID))
    }

    #if DEBUG
    init(previewViewModel: ThreadsViewModel) {
        self.visualizationID = "preview"
        self._viewModel = State(initialValue: previewViewModel)
    }
    #endif

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Text("Threads")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.appTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 25)

            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if viewModel.comments.isEmpty {
                        Text("No threads yet")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.appTeal)
                            .padding(.top, 80)
                        Text("Start a new thread or wait for conversations to appear here.")
                            .foregroundStyle(.secondary)
                            .padding(.top, 5)
                            .padding(.horizontal, 30)
                    } else {
                        ForEach(viewModel.comments) { comment in
                            ThreadCommentRow(
                                comment: comment,
                                currentUserID: currentUser?.id,
                                activeCommentID: $activeCommentID,
                                activeCommentAuthor: $activeCommentAuthor
                            ){ commentID, authorID in
                                guard let user = currentUser else { return }
                                Task {
                                    await viewModel.deleteComment(
                                        commentID: commentID,
                                        authorID: authorID,
                                        currentUserID: user.id
                                    )
                                }
                            } onDeleteReply: { commentID, replyID, authorID in
                                guard let user = currentUser else { return }
                                Task {
                                    await viewModel.deleteReply(
                                        commentID: commentID,
                                        replyID: replyID,
                                        authorID: authorID,
                                        currentUserID: user.id
                                    )
                                }
                            }
                        }
                    }
                    Spacer(minLength: 16)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .task {
                await fetchCurrentUser()
                await viewModel.loadComments()
            }
            .safeAreaInset(edge: .bottom) {
                if !isCollapsed {
                    replyInputBar
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activeCommentID)
    }

    // MARK: - Subviews
    @ViewBuilder
    private var replyInputBar: some View {
        VStack(spacing: 0) {
            
            // Chip que aparece solo cuando estás respondiendo
            if let author = activeCommentAuthor {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTeal)
                    
                    Text("Replying to \(author)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTeal)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            activeCommentID = nil
                            activeCommentAuthor = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 8)
                .background()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            ReplyField(
                text: $replyText,
                placeholder: activeCommentID == nil ? "Start a new thread. . ." : "Write your reply...",
                isActive: true
            ) {
                submitReply()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .animation(.easeInOut(duration: 0.2), value: activeCommentID)
    }

    // MARK: - Private Methods

    private func fetchCurrentUser() async {
        guard let firebaseUser = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        let db = Firestore.firestore()
        do {
            let doc = try await db
                .collection("users")
                .document(firebaseUser.uid)
                .getDocument()
            guard let data = doc.data() else { return }
            
            currentUser = AppUser(
                id: doc.documentID,
                email: data["email"] as? String ?? "",
                profilePictureURL: data["profilePictureURL"] as? String,
                username: data["username"] as? String ?? ""
            )
            print("User loaded: \(currentUser?.username ?? "nil")")
        } catch {
            print("Error fetching user: \(error)")
        }
    }

    private func submitReply() {
        let trimmed = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let user = currentUser else { return }

        Task {
            if let commentID = activeCommentID {
                await viewModel.postReply(
                    to: commentID,
                    content: trimmed,
                    author: user
                )
            } else {
                await viewModel.postComment(
                    content: trimmed,
                    author: user
                )
            }
            replyText = ""
            withAnimation {
                activeCommentID = nil
                activeCommentAuthor = nil
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ThreadsView(previewViewModel: .preview())
}
