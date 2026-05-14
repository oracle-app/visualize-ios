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

    @State private var viewModel: ThreadsViewModel
    @State private var replyText = ""
    @State private var activeCommentID: String? = nil  // Tracks which comment is being replied to
    @State private var currentUser: AppUser? = nil

    // MARK: - Init

    init(visualizationID: String = "3nlO5I3PoEWAaKzwfcKB") {
        self.visualizationID = visualizationID
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

            VStack(spacing: 8) {
                Text("Threads")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.appTeal)
            }
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
                                activeCommentID: $activeCommentID
                            )
                        }
                    }
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .task {
                await fetchCurrentUser()
                await viewModel.loadComments()
            }
            .safeAreaInset(edge: .bottom) {
                replyInputBar
            }
            .animation(.easeInOut(duration: 0.2), value: activeCommentID)
        }
    }

    // MARK: - Subviews

    /// Animated bottom bar shown when the user is replying to a comment.
    @ViewBuilder
    private var replyInputBar: some View {
        if activeCommentID != nil {
            VStack(spacing: 0) {
                ReplyField(text: $replyText, isActive: true) {
                    submitReply()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Private Methods

    /// Fetches the current Firebase authenticated user from Firestore.
    private func fetchCurrentUser() async {
        guard let firebaseUser = Auth.auth().currentUser else { return }

        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(firebaseUser.uid)
                .getDocument()

            currentUser = try doc.data(as: AppUser.self)
        } catch {
            print("Error fetching current user: \(error)")
        }
    }

    /// Validates and submits the reply, then resets the input state.
    private func submitReply() {
        guard let commentID = activeCommentID,
              !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let user = currentUser
        else { return }

        Task {
            await viewModel.postReply(
                to: commentID,
                content: replyText,
                author: user
            )
            replyText = ""
            withAnimation { activeCommentID = nil }
            await viewModel.loadComments()
        }
    }
}

// MARK: - Preview

#Preview {
    ThreadsView(previewViewModel: .preview())
}
