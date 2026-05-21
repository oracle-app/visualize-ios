//
//  ThreadsPreviewView.swift
//  visualize
//
//  Created by Ruben Castro on 20/05/26.
//
//  Preview screen shown after the user confirms their edits in
//  `SnipEditorView` and before publishing to Threads.
//  - Top toolbar: "Go back" button (left) and "Post to Threads" paperplane
//    button (right, glassEffect orange tint to match the project style).
//  - Title: "Preview", centered.
//  - Caption / comment section with placeholder and multiline support.
//  - Edited visualization image container with loading and failure states
//    for the edge cases listed in the ticket.
//  - Confirmation modal "Share as new thread?" with Share / Cancel actions.
//
//  This screen is UI-only: it does not integrate with the Threads publishing
//  logic. The actual upload is delegated to the parent through `onShare`.

import SwiftUI

struct ThreadsPreviewView: View {

    // MARK: - Properties

    let editedImage: UIImage
    let onShare: (UIImage, String?) -> Void
    let onDismiss: () -> Void

    // MARK: - State

    @State private var viewModel: ThreadsPreviewViewModel
    @FocusState private var isCaptionFocused: Bool
    /// Controls the "Discard changes?" confirmation shown when the user
    /// taps the back button. Prevents losing the typed caption by accident.
    @State private var showDiscardAlert: Bool = false

    // MARK: - Init

    init(
        editedImage: UIImage,
        onShare: @escaping (UIImage, String?) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.editedImage = editedImage
        self.onShare = onShare
        self.onDismiss = onDismiss
        self._viewModel = State(initialValue: ThreadsPreviewViewModel())
    }

    #if DEBUG
    init(
        editedImage: UIImage,
        previewViewModel: ThreadsPreviewViewModel,
        onShare: @escaping (UIImage, String?) -> Void = { _, _ in },
        onDismiss: @escaping () -> Void = {}
    ) {
        self.editedImage = editedImage
        self.onShare = onShare
        self.onDismiss = onDismiss
        self._viewModel = State(initialValue: previewViewModel)
    }
    #endif

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                // Built manually (not as a `.toolbar`) to match the exact
                // glassEffect button style used in `FSHeaderView` and
                // `ResetPassword`. Wrapping these buttons in `ToolbarItem`
                // adds an extra material backdrop behind the glass and
                // produces a faint dark halo, which is the visual bug we
                // want to avoid here.
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 24) {

                        ThreadsPreviewCaptionField(
                            text: $viewModel.caption,
                            limit: viewModel.captionLimit
                        )
                        .focused($isCaptionFocused)
                        .onChange(of: viewModel.caption) { _, _ in
                            viewModel.clampCaptionIfNeeded()
                        }

                        ThreadsPreviewImageContainer(
                            image: editedImage,
                            state: viewModel.imageState
                        )

                        // Reserve space so the keyboard doesn't push the
                        // image container out of view when the caption
                        // field is focused.
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .alert("Discard changes?", isPresented: $showDiscardAlert) {
            Button("Discard", role: .destructive) { onDismiss() }
            Button("Continue", role: .cancel) {}
        } message: {
            Text("If you go back, your caption will not be saved.")
        }
        .alert("Share as new thread?", isPresented: $viewModel.showShareConfirmation) {
            Button("Share") {
                onShare(editedImage, viewModel.captionForShare)
                onDismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This edited visualization will be shared as a new thread.")
        }
    }

    // MARK: - Subviews

    /// Header row with the back button (left), the "Preview" title (centered),
    /// and the share button (right). Buttons use the same glassEffect treatment
    /// as the rest of the app — see `FSHeaderView` for the matching pattern.
    private var header: some View {
        ZStack {
            // Centered title — sits in its own layer so the side buttons
            // never push it off center, regardless of their widths.
            Text("Preview")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.appNavy)

            HStack {
                // MARK: Go back
                Button {
                    // Dismiss the keyboard before showing the alert so
                    // the modal isn't pushed up by the caption field.
                    isCaptionFocused = false
                    showDiscardAlert = true
                } label: {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.primaryText)
                        .frame(width: 48, height: 48)
                        .glassEffect()
                }
                .accessibilityLabel("Go back")

                Spacer()

                // MARK: Post to Threads
                Button {
                    isCaptionFocused = false
                    viewModel.requestShare()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .glassEffect(.regular.tint(Color.primaryOrange), in: Circle())
                }
                .accessibilityLabel("Post to Threads")
                // The share button is gated on a successfully loaded image:
                // it would be misleading to let the user post a failed/loading
                // preview to Threads.
                .disabled(viewModel.imageState != .loaded)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Default") {
    ThreadsPreviewView(
        editedImage: UIImage(systemName: "chart.xyaxis.line") ?? UIImage(),
        previewViewModel: ThreadsPreviewViewModel()
    )
}

#Preview("Failed image") {
    ThreadsPreviewView(
        editedImage: UIImage(),
        previewViewModel: ThreadsPreviewViewModel(initialImageState: .failed)
    )
}

#Preview("Loading image") {
    ThreadsPreviewView(
        editedImage: UIImage(),
        previewViewModel: ThreadsPreviewViewModel(initialImageState: .loading)
    )
}
#endif
