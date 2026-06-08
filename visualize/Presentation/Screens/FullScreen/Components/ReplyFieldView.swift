//
//  ReplyField.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
///  A SwiftUI View that provides a dynamic, auto-expanding text input field.
///
///  Responsibilities:
///  - Captures textual input from the user using a multi-line vertical layout container.
///  - Monitors structural focus state variables to programmatically toggle the system keyboard.
///  - Validates interactive text length parameters to animate the presentation of the submission trigger.
///  - Styles the background layer using an ultra-thin capsule material complete with a custom stroke ring overlay.


import SwiftUI

struct ReplyFieldView: View {

    // MARK: - Properties
    /// A two-way reactive data connection mirroring the textual contents managed by the parent container frame.
    @Binding var text: String
    /// The localized contextual string placeholder displayed prior to user character input. Defaults to `"Start a new thread. . ."`.
    var placeholder: String = "Start a new thread. . ."
    /// An initial state flag to determine if this input cell should gain first responder status upon rendering.
    var isActive: Bool = false
    /// An execution closure action block triggered when the user commits their data entry payload by clicking the send element.
    var onSend: () -> Void = {}

    @FocusState private var focused: Bool
    
    private let minHeight: CGFloat = 40
    private let maxHeight: CGFloat = 120
    /// Computes a boolean indicating if the input element contains printable characters following whitespace truncation passes.
    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            textInput
            if hasText {
                sendButton
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: hasText)
        .onChange(of: isActive) { _, newValue in
            focused = newValue
        }
    }

    // MARK: - Subviews

    /// Capsule-shaped text field with a microphone button on the trailing side.
    private var textInput: some View {
        HStack (alignment: .bottom){
            TextField(placeholder, text: $text, axis: .vertical)
                .focused($focused)
                .font(.system(size: 17))
                .foregroundStyle(Color.primaryText)
                .lineLimit(1...4)
                .padding(.horizontal, 6)
                .padding(.vertical, 8)
                .background(Color.clear)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color.clear)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.4), lineWidth: 1)
                )
        )
    }

    /// Send button, visible only when the field has non-empty text.
    private var sendButton: some View {
        Button {
            onSend()
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.appTeal)
                )
        }
        .padding(.bottom, 2)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        ReplyFieldView(text: .constant(""))
        ReplyFieldView(text: .constant("This is a longer message that should expand the text field vertically as more content is added."))
    }
    .background(Color.gray.opacity(0.2))
}
