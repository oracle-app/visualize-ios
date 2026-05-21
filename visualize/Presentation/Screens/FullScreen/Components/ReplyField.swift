//
//  ReplyField.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
//  Input bar for composing and sending a thread reply.
//  - Animates a send button into view when the field has text
//  - Auto-focuses the text field when isActive becomes true
//  - Calls onSend when the send button is tapped

import SwiftUI

struct ReplyField: View {

    // MARK: - Properties

    @Binding var text: String
    var isActive: Bool = false
    var onSend: () -> Void = {}

    @FocusState private var focused: Bool

    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            textInput
            if hasText {
                sendButton
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.2), value: hasText)
        .onChange(of: isActive) { _, newValue in
            focused = newValue
        }
    }

    // MARK: - Subviews

    /// Capsule-shaped text field with a microphone button on the trailing side.
    private var textInput: some View {
        HStack {
            TextField("Reply . . .", text: $text)
                .foregroundStyle(.black)
                .font(.system(size: 20))
                .focused($focused)

            Spacer()

            Button {
                // TODO: Microphone input
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .frame(height: 40)
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
    }
}

// MARK: - Preview

#Preview {
    ReplyField(text: .constant(""))
}
