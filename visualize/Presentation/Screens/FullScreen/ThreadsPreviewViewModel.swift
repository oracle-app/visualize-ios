//
//  ThreadsPreviewViewModel.swift
//  visualize
//
//  Created by Ruben Castro on 20/05/26.
//
//  Drives the Threads Preview screen, the step shown right after the user
//  confirms their edits in `SnipEditorView` and before publishing to Threads.
//  - Holds the optional caption typed by the user
//  - Tracks the loading / loaded / failed state of the preview image
//  - Exposes the toggle for the "Share as new thread?" confirmation modal
//
//  The screen is presentation-only (no Threads publishing logic here);
//  the actual upload is performed by the parent via the `onShare` callback
//  once the user confirms in the modal.

import SwiftUI
import Observation

// MARK: - ImageLoadState

/// Lifecycle of the edited visualization image displayed in the preview.
/// `SnipEditorView` already exports a `UIImage`, so the typical path is
/// `.loaded` from the start. The `.loading` and `.failed` states are kept
/// to cover the edge cases listed in the ticket (slow rendering, image
/// fails to load) and any future asynchronous source.
enum ImageLoadState: Equatable {
    case loading
    case loaded
    case failed
}

// MARK: - ThreadsPreviewViewModel

@MainActor
@Observable
final class ThreadsPreviewViewModel {

    // MARK: - Caption

    /// Optional caption typed in the multiline input area.
    /// Trimmed, length-clamped accessors are provided below.
    var caption: String = ""

    /// Hard cap on caption length. Matches the "Comment exceeds expected length"
    /// edge case from the ticket: input is clipped at the view layer using this value.
    let captionLimit: Int = 500

    /// Whether the caption is empty after trimming whitespace and newlines.
    /// Used by the view to decide if the placeholder should be shown.
    var isCaptionEmpty: Bool {
        caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Caption value the parent receives when the user confirms the share.
    /// Returns `nil` for an empty caption so downstream callers can treat
    /// "no caption" distinctly from "empty string".
    var captionForShare: String? {
        isCaptionEmpty ? nil : caption
    }

    // MARK: - Image state

    /// Current load state for the edited visualization image.
    /// Defaults to `.loaded` because the image is passed in synchronously
    /// from `SnipEditorView`; callers may override via `setImageState(_:)`
    /// when sourcing the image asynchronously.
    private(set) var imageState: ImageLoadState = .loaded

    // MARK: - Modal state

    /// Toggles the "Share as new thread?" confirmation modal.
    /// The view binds this to `.alert(isPresented:)`.
    var showShareConfirmation: Bool = false

    // MARK: - Init

    init(initialImageState: ImageLoadState = .loaded) {
        self.imageState = initialImageState
    }

    // MARK: - Public Methods

    /// Updates the image load state. Called by the view when the image
    /// finishes rendering or fails to load.
    func setImageState(_ state: ImageLoadState) {
        imageState = state
    }

    /// Clamps the caption to `captionLimit` characters.
    /// Called from the view's `onChange(of: caption)` so the input area
    /// never exceeds the expected length, covering the edge case where
    /// the user pastes a long block of text.
    func clampCaptionIfNeeded() {
        if caption.count > captionLimit {
            caption = String(caption.prefix(captionLimit))
        }
    }

    /// Opens the confirmation modal. Invoked by the share toolbar button.
    func requestShare() {
        showShareConfirmation = true
    }
}
