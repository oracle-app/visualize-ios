//
//  ReplyField.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
//  Input bar for composing and sending a thread reply or new thread.
//  - Grows vertically as the user types
//  - Animates a send button into view when the field has text
//  - Calls onSend when the send button is tapped

import SwiftUI

struct ReplyFieldView: View {

    // MARK: - Properties

    @Binding var text: String
    var placeholder: String = "Start a new thread. . ."
    var isActive: Bool = false
    var onSend: () -> Void = {}

    @FocusState private var focused: Bool
    
    private let minHeight: CGFloat = 40
    private let maxHeight: CGFloat = 120

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
                .foregroundStyle(AppColors.Text.primary)
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
                        .fill(AppColors.Brand.teal)
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
