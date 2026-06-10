//
//  ThreadsView.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.

///  A SwiftUI View that represents the main interface for comment threads.
///
///  Responsibilities:
///  - Displays a scrollable list of root comments and their nested replies.
///  - Manages UI states for loading indicators, empty states, and error alerts.
///  - Provides a contextual input bar that toggles dynamically between posting
///    a brand new thread or replying to a specific author.
///  - Handles real-time interface animations when focus changes or items are deleted.
///  - Automatically cleans up text fields and active focus variables upon successful submission.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ThreadScreen: View {
    
    // MARK: - Properties
    
    let visualizationID: String
    let visualizationOwnerID: String
    var isCollapsed: Bool = false
    
    @State private var viewModel: ThreadScreenViewModel
    @State private var replyText = ""
    @State private var activeCommentID: String? = nil
    @State private var activeCommentAuthor: String? = nil
    @State private var showError = false
    @FocusState private var isInputFocused: Bool

    // MARK: - Init
    /// Creates a standard production instance of `ThreadScreen`.
    ///
    /// - Parameters:
    ///   - visualizationID: The parent visualization resource identifier.
    ///   - visualizationOwnerID: The unique identifier of the user who owns the visualization.
    ///   - isCollapsed: A structural flag to hide the bottom input utility bar if required. Defaults to `false`.
    ///   - viewModel: The business logic container state manager driving this interface.

    init(
        visualizationID: String,
        visualizationOwnerID: String,
        isCollapsed: Bool = false,
        viewModel: ThreadScreenViewModel
    ) {
        self.visualizationID = visualizationID
        self.visualizationOwnerID = visualizationOwnerID
        self.isCollapsed = isCollapsed
        self._viewModel = State(initialValue: viewModel)
    }

    #if DEBUG
    /// Creates a dedicated instance of `ThreadScreen` configured specifically with mock values for Canvas Previews.
    ///
    /// - Parameter previewViewModel: A customized pre-loaded view model container.
    init(previewViewModel: ThreadScreenViewModel) {
        self.visualizationID = "preview"
        self.visualizationOwnerID = "preview"
        self._viewModel = State(initialValue: previewViewModel)
    }
    #endif

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Text("Threads")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppColors.Brand.teal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 25)
            
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if viewModel.comments.isEmpty {
                        Text(String(localized: "No threads yet"))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppColors.Brand.teal)
                            .padding(.top, 80)
                        Text(String(localized: "Start a new thread or wait for conversations to appear here."))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                            .padding(.horizontal, 30)
                    } else {
                        ForEach(viewModel.comments) { comment in
                            ThreadCommentRowView(
                                comment: comment,
                                currentUserID: viewModel.currentUser?.id,
                                canDelete: { authorID in
                                    viewModel.permissions?.canDeleteComment(commentAuthorID: authorID) ?? false
                                },
                                activeCommentID: $activeCommentID,
                                activeCommentAuthor: $activeCommentAuthor
                            ) { commentID, authorID in
                                Task {
                                    await viewModel.deleteComment(
                                        commentID: commentID,
                                        authorID: authorID
                                    )
                                }
                            } onDeleteReply: { commentID, replyID, authorID in
                                Task {
                                    await viewModel.deleteReply(
                                        commentID: commentID,
                                        replyID: replyID,
                                        authorID: authorID
                                    )
                                }
                            }
                        }
                    }
                    Spacer(minLength: 16)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .task {
                await viewModel.fetchCurrentUser()
                await viewModel.loadComments()
            }
            if !isCollapsed {
                replyInputBar
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activeCommentID)
        .onChange(of: viewModel.error) { _, newError in
            if newError != nil {
                showError = true
            }
        }
        .alert(String(localized: "An error has happened"), isPresented: $showError) {
            Button(String(localized: "OK"), role: .cancel) {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error ?? "")
        }
        
    }

    // MARK: - Subviews
    /// A contextual input header and text field component placed at the bottom of the screen.
    ///
    /// Dynamically changes its look and placeholder depending on whether the user is typing a root thread
    /// or replying to an existing conversation cell node.
    @ViewBuilder
    private var replyInputBar: some View {
        VStack(spacing: 0) {
            
            if let author = activeCommentAuthor {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.Brand.teal)
                    
                    Text("Replying to \(author)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.Brand.teal)
                    
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
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            ReplyFieldView(
                text: $replyText,
                placeholder: activeCommentID == nil ? String(localized: "Start a new thread. . .") : String(localized: "Write your reply..."),
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
    
    /// Trims whitespace and validates input layout from the user before committing database records.
    ///
    /// Automatically branches tasks asynchronously between `postReply` or `postComment` depending
    /// on the state of `activeCommentID`. Resets interaction variables smoothly after finishing.
    private func submitReply() {
        let trimmed = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            if let commentID = activeCommentID {
                await viewModel.postReply(
                    to: commentID,
                    content: trimmed
                )
            } else {
                await viewModel.postComment(
                    content: trimmed
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
    ThreadScreen(previewViewModel: .preview())
}
