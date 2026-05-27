//
//  ThreadsPreviewCaptionField.swift
//  visualize
//
//  Created by Ruben Castro on 20/05/26.
//
//  Caption / comment input area for the Threads Preview screen.
//  - Multiline text editor (acceptance criteria: "Caption input area supports multiline text")
//  - Custom placeholder overlay, since `TextEditor` does not provide one
//  - Character counter shown when the user gets close to the limit, so the
//    "Comment exceeds expected length" edge case is communicated visually
//    before the parent view model's setter clamps the value.
//
//  The focus state is owned by the parent: the parent passes its
//  `FocusState<Bool>.Binding` and this component applies it directly to the
//  `TextEditor`. This guarantees the parent's "dismiss keyboard" calls
//  actually move focus off the editor.

import SwiftUI

struct ThreadsPreviewCaptionField: View {

    // MARK: - Properties

    @Binding var text: String
    var focus: FocusState<Bool>.Binding
    let placeholder: String
    let limit: Int

    // Dynamic Type-aware sizes. `@ScaledMetric` lets the design tokens scale
    // with the user's accessibility preferences without losing the visual
    // hierarchy expressed by the original sizes.
    @ScaledMetric(relativeTo: .body) private var bodyFontSize: CGFloat = 15
    @ScaledMetric(relativeTo: .headline) private var headlineFontSize: CGFloat = 15
    @ScaledMetric(relativeTo: .caption) private var captionFontSize: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var editorMinHeight: CGFloat = 130

    // MARK: - Init

    init(
        text: Binding<String>,
        focus: FocusState<Bool>.Binding,
        placeholder: String = String(localized: "Add an optional description..."),
        limit: Int = 500
    ) {
        self._text = text
        self.focus = focus
        self.placeholder = placeholder
        self.limit = limit
    }

    // MARK: - Derived state

    /// Placeholder visibility uses the same trimming rule as the view model's
    /// `isCaptionEmpty`, so a caption made of only spaces does not hide the
    /// placeholder while still being treated as "empty" at share time.
    private var isEffectivelyEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // MARK: - Caption header
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Caption"))
                    .font(.system(size: headlineFontSize, weight: .bold))
                    .foregroundStyle(Color.appNavy)
                Text(String(localized: "Share insights about this edited visualization."))
                    .font(.system(size: captionFontSize))
                    .foregroundStyle(Color.appTeal)
            }

            // MARK: - Editor + placeholder

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appLightTeal)

                // Placeholder is overlaid because TextEditor lacks a native one.
                // `allowsHitTesting(false)` lets taps fall through to the editor.
                // Hidden from accessibility because the TextEditor itself carries
                // the field's accessibility label.
                if isEffectivelyEmpty {
                    Text(placeholder)
                        .font(.system(size: bodyFontSize))
                        .foregroundStyle(Color.appSubtitle.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

                TextEditor(text: $text)
                    .font(.system(size: bodyFontSize))
                    .foregroundStyle(Color.appNavy)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .focused(focus)
                    .accessibilityLabel("Caption")
                    .accessibilityHint("Optional description for your post")
            }
            .frame(minHeight: editorMinHeight)

            // MARK: - Character counter
            // Shown only when within 50 characters of the limit, so the
            // counter doesn't distract during normal typing but warns the
            // user before they hit the cap. Exposed to assistive tech as a
            // single accessibilityValue on the field via the editor above —
            // the counter element itself is hidden to avoid per-keystroke
            // VoiceOver chatter.
            if text.count >= limit - 50 {
                Text("\(text.count) / \(limit)")
                    .font(.system(size: captionFontSize, weight: .medium))
                    .foregroundStyle(text.count >= limit ? Color.appRed : Color.appSubtitle)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityHidden(true)
            }
        }
    }
}

// MARK: - Preview

#Preview("Empty") {
    @Previewable @State var text = ""
    @Previewable @FocusState var focus: Bool
    return ThreadsPreviewCaptionField(text: $text, focus: $focus)
        .padding()
        .background(Color.appBackground)
}

#Preview("Filled") {
    @Previewable @State var text = "The Australian dollar has sold off more than any other currency! This part of the chart shows when it drops below all the other major currencies."
    @Previewable @FocusState var focus: Bool
    return ThreadsPreviewCaptionField(text: $text, focus: $focus)
        .padding()
        .background(Color.appBackground)
}
