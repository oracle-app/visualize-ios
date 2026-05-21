//
//  ThreadsPreviewView.swift
//  visualize
//
//  Created by Ruben Castro on 20/05/26.
//
//  Preview screen shown after the user confirms their edits in
//  `SnipEditorView` and before publishing to Threads.
//  - Top header: "Go back" button (left) and "Post to Threads" paperplane
//    button (right), both using the project's standard `glassEffect` style.
//  - Title: "Preview", centered.
//  - Caption / comment section with placeholder and multiline support.
//  - Edited visualization image container with a failure layout for the
//    edge case where the image cannot be displayed.
//  - Unified confirmation alert driven by a single `ThreadsPreviewAlert`
//    enum on the view model, so discard and share alerts can never race.
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
    /// Single source of truth for the caption field's focus. The child
    /// component receives this as a `FocusState<Bool>.Binding` and applies
    /// it directly to the underlying `TextEditor`, so toggling it here
    /// actually dismisses the keyboard.
    @FocusState private var isCaptionFocused: Bool

    // Dynamic Type-aware sizing for the header.
    @ScaledMetric(relativeTo: .title3) private var titleFontSize: CGFloat = 22
    @ScaledMetric(relativeTo: .title3) private var buttonIconSize: CGFloat = 22
    @ScaledMetric(relativeTo: .body) private var buttonDiameter: CGFloat = 48

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
                // produces a faint dark halo.
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 24) {

                        ThreadsPreviewCaptionField(
                            text: $viewModel.caption,
                            focus: $isCaptionFocused,
                            limit: viewModel.captionLimit
                        )

                        ThreadsPreviewImageContainer(image: editedImage)

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
        // Single alert binding driven by the view model's `presentedAlert`.
        // This replaces the two boolean alerts used previously, eliminating
        // the race where both flags could flip true within the same tick.
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

    // MARK: - Subviews

    /// Header row with the back button (left), the "Preview" title (centered),
    /// and the share button (right). Buttons use the same glassEffect treatment
    /// as the rest of the app — see `FSHeaderView` for the matching pattern.
    private var header: some View {
        ZStack {
            // Centered title — sits in its own layer so the side buttons
            // never push it off center, regardless of their widths.
            Text("Preview")
                .font(.system(size: titleFontSize, weight: .bold))
                .foregroundStyle(Color.appNavy)

            HStack {
                // MARK: Go back
                Button {
                    // Dismiss the keyboard before showing the alert so
                    // the modal isn't pushed up by the caption field.
                    isCaptionFocused = false
                    viewModel.requestDiscard()
                } label: {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: buttonIconSize))
                        .foregroundStyle(Color.primaryText)
                        .frame(width: buttonDiameter, height: buttonDiameter)
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
                        .font(.system(size: buttonIconSize))
                        .foregroundStyle(Color.white)
                        .frame(width: buttonDiameter, height: buttonDiameter)
                        .glassEffect(.regular.tint(Color.primaryOrange), in: Circle())
                }
                .accessibilityLabel("Post to Threads")
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
#endif
