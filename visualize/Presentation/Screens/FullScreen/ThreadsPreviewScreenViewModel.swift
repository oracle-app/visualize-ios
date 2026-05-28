//
//  ThreadsPreviewViewModel.swift
//  visualize
//
//  Created by Ruben Castro on 20/05/26.
//
//  Drives the Threads Preview screen, the step shown right after the user
//  confirms their edits in `SnipEditorView` and before publishing to Threads.
//  - Holds the optional caption typed by the user
//  - Exposes a single `presentedAlert` so the view never tries to render
//    two `.alert` modifiers at once (which can race when both flags flip
//    in the same runloop tick).
//
//  The screen is presentation-only (no Threads publishing logic here);
//  the actual upload is performed by the parent via the `onShare` callback
//  once the user confirms in the modal.

import SwiftUI
import Observation

// MARK: - AlertKind

/// Identifies which confirmation alert the preview screen is currently showing.
/// A single `Identifiable` enum is used so the view binds to one `.alert(item:)`
/// instead of two independent boolean alerts that could race each other.
enum ThreadsPreviewAlert: Identifiable {
    case discard
    case share
    var id: Self { self }
}

// MARK: - ThreadsPreviewViewModel

@MainActor
@Observable
final class ThreadsPreviewScreenViewModel {

    // MARK: - Caption

    /// Optional caption typed in the multiline input area. The setter is the
    /// single source of truth for length clamping: whenever the view binds
    /// to `caption` and the user types or pastes text, the setter ensures
    /// the value never exceeds `captionLimit`. This avoids the double-write
    /// problem that produces cursor jumps in `TextEditor`.
    var caption: String = "" {
        didSet {
            if caption.count > captionLimit {
                caption = String(caption.prefix(captionLimit))
            }
        }
    }

    /// Hard cap on caption length. Matches the "Comment exceeds expected length"
    /// edge case from the ticket.
    let captionLimit: Int = 500

    /// Whether the caption is empty after trimming whitespace and newlines.
    /// The view uses this same rule to decide if the placeholder should be
    /// shown — keeping placeholder visibility and "empty" semantics aligned.
    var isCaptionEmpty: Bool {
        trimmedCaption.isEmpty
    }

    /// Caption value the parent receives when the user confirms the share.
    /// Returns `nil` for an empty caption so downstream callers can treat
    /// "no caption" distinctly from "empty string". When non-nil, the value
    /// is trimmed so trailing whitespace or newlines never leak downstream.
    var captionForShare: String? {
        isCaptionEmpty ? nil : trimmedCaption
    }

    /// Caption with leading/trailing whitespace and newlines removed.
    /// Exposed for the view so placeholder visibility uses the same rule.
    var trimmedCaption: String {
        caption.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Alert state

    /// Currently presented alert, if any. The view binds this to a single
    /// `.alert(item:)` so discard and share confirmations can never overlap.
    var presentedAlert: ThreadsPreviewAlert?

    // MARK: - Public Methods

    /// Opens the "Share as new thread?" confirmation modal. Invoked by the
    /// share toolbar button.
    func requestShare() {
        presentedAlert = .share
    }

    /// Opens the "Discard changes?" confirmation modal. Invoked by the
    /// back toolbar button.
    func requestDiscard() {
        presentedAlert = .discard
    }

    /// Dismisses any currently-presented alert.
    func dismissAlert() {
        presentedAlert = nil
    }
}
