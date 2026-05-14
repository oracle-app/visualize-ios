//
//  ThreadsView.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
import SwiftUI

struct ThreadsView: View {
    let visualizationID: String

    @State private var viewModel: ThreadsViewModel
    @State private var replyText = ""
    @State private var activeCommentID: String? = nil

    init(visualizationID: String = "3nlO5I3PoEWAaKzwfcKB") {
        self.visualizationID = visualizationID
        self._viewModel = State(initialValue: ThreadsViewModel(visualizationID: visualizationID))
    }

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 8) {
                Text("Threads")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if viewModel.comments.isEmpty {
                        Text("No threads yet")
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
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
                await viewModel.loadComments()
            }

            .safeAreaInset(edge: .bottom) {
                if activeCommentID != nil {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.left.fill")
                                .foregroundStyle(Color.appThreadsReply)
                            Text("Replying to thread . . .")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button {
                                withAnimation { activeCommentID = nil }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 8)

                        ReplyField(text: $replyText, isActive: true) {
                            guard let commentID = activeCommentID,
                                  !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            else { return }

                            Task {
                                let mockUser = AppUser(
                                    id: "e9Nk8XrxHJAtwN3Hf2FL",
                                    email: "example1@gmail.com",
                                    profilePictureURL: nil,
                                    username: "Pedro Perez"
                                )
                                await viewModel.postReply(
                                    to: commentID,
                                    content: replyText,
                                    author: mockUser
                                )
                                replyText = ""
                                withAnimation { activeCommentID = nil }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .background(.ultraThinMaterial)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: activeCommentID)
        }
    }
}

#Preview {
    ThreadsView(visualizationID: "3nlO5I3PoEWAaKzwfcKB")
}
