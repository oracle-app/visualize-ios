//
//  ThreadsPreviewScreen.swift
//  visualize
//
//  Created by Ruben Castro on 20/05/26.
//
//  Preview screen shown after the user confirms their edits in
//  `SnipEditorScreen` and before publishing to Threads.
//  - Toolbar: "Go back" (left), "Preview" title, "Post to Threads" (right).
//  - Caption / comment section with placeholder and multiline support.
//  - Edited visualization image container with a failure layout for the
//    edge case where the image cannot be displayed.
//  - Unified confirmation alert driven by a single `ThreadsPreviewAlert`
//    enum on the view model, so discard and share alerts can never race.
//
//  This screen is UI-only: it does not integrate with the Threads publishing
//  logic. The actual upload is delegated to the parent through `onShare`.

import SwiftUI

struct ThreadsPreviewScreen: View {

    // MARK: - Properties

    let editedImage: UIImage
    let onShare: (UIImage, String?) -> Void
    let onDismiss: () -> Void

    // MARK: - State

    @State private var viewModel: ThreadsPreviewScreenViewModel
    @FocusState private var isCaptionFocused: Bool

    // MARK: - Init

    init(
        editedImage: UIImage,
        onShare: @escaping (UIImage, String?) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.editedImage = editedImage
        self.onShare = onShare
        self.onDismiss = onDismiss
        self._viewModel = State(initialValue: ThreadsPreviewScreenViewModel())
    }

    #if DEBUG
    init(
        editedImage: UIImage,
        previewViewModel: ThreadsPreviewScreenViewModel,
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
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        ThreadsPreviewCaptionFieldView(
                            text: $viewModel.caption,
                            focus: $isCaptionFocused,
                            limit: viewModel.captionLimit
                        )

                        ThreadsPreviewImageContainerView(image: editedImage)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Go back", systemImage: "arrow.backward") {
                        isCaptionFocused = false
                        viewModel.requestDiscard()
                    }
                    .tint(Color.appNavy)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Post to Threads", systemImage: "paperplane.fill") {
                        isCaptionFocused = false
                        viewModel.requestShare()
                    }
                    .tint(Color.primaryOrange)
                }
            }
            .alert(item: $viewModel.presentedAlert) { kind in
                switch kind {
                case .discard:
                    return Alert(
                        title: Text("Discard changes?"),
                        message: Text("If you go back, your caption will not be saved."),
                        primaryButton: .destructive(Text("Discard")) {
                            viewModel.dismissAlert()
                            onDismiss()
                        },
                        secondaryButton: .cancel(Text("Continue")) {
                            viewModel.dismissAlert()
                        }
                    )
                case .share:
                    return Alert(
                        title: Text("Share as new thread?"),
                        message: Text("This edited visualization will be shared as a new thread."),
                        primaryButton: .default(Text("Share")) {
                            onShare(editedImage, viewModel.captionForShare)
                            viewModel.dismissAlert()
                            onDismiss()
                        },
                        secondaryButton: .cancel(Text("Cancel")) {
                            viewModel.dismissAlert()
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Default") {
    ThreadsPreviewScreen(
        editedImage: UIImage(systemName: "chart.xyaxis.line") ?? UIImage(),
        previewViewModel: ThreadsPreviewScreenViewModel()
    )
}
#endif
