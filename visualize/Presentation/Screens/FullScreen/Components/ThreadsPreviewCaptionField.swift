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
//    before the value is clamped by the view model.

import SwiftUI

struct ThreadsPreviewCaptionField: View {

    // MARK: - Properties

    @Binding var text: String
    let placeholder: String
    let limit: Int

    @FocusState private var isFocused: Bool

    // MARK: - Init

    init(
        text: Binding<String>,
        placeholder: String = "Add an optional description...",
        limit: Int = 500
    ) {
        self._text = text
        self.placeholder = placeholder
        self.limit = limit
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // MARK: - Caption header
            VStack(alignment: .leading, spacing: 2) {
                Text("Caption")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.appNavy)
                Text("Share insights about this edited visualization.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTeal)
            }

            // MARK: - Editor + placeholder

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appLightTeal)

                // Placeholder is overlaid because TextEditor lacks a native one.
                // `allowsHitTesting(false)` lets taps fall through to the editor.
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.appSubtitle.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.appNavy)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .focused($isFocused)
                    // Clamp in-line as a safety net in addition to the
                    // view model's `clampCaptionIfNeeded`. Belt and braces:
                    // if a parent ever drives `text` past `limit`, the UI
                    // still corrects it.
                    .onChange(of: text) { _, newValue in
                        if newValue.count > limit {
                            text = String(newValue.prefix(limit))
                        }
                    }
            }
            .frame(minHeight: 130)

            // MARK: - Character counter
            // Shown only when within 50 characters of the limit, so the
            // counter doesn't distract during normal typing but warns the
            // user before they hit the cap.
            if text.count >= limit - 50 {
                Text("\(text.count) / \(limit)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(text.count >= limit ? Color.appRed : Color.appSubtitle)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

// MARK: - Preview

#Preview("Empty") {
    @Previewable @State var text = ""
    return ThreadsPreviewCaptionField(text: $text)
        .padding()
        .background(Color.appBackground)
}

#Preview("Filled") {
    @Previewable @State var text = "The Australian dollar has sold off more than any other currency! This part of the chart shows when it drops below all the other major currencies."
    return ThreadsPreviewCaptionField(text: $text)
        .padding()
        .background(Color.appBackground)
}
