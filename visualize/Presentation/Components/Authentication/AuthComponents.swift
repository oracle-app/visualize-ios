//
//  AuthComponents.swift
//  VisualizeApp
//
//  Created by Libia Fv on 19/04/26.
//
// Description:
//  Reusable SwiftUI components for authentication UI.
//  Includes input fields, a password field, and a styled button.

import SwiftUI

struct InputField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Color.appLightTeal)
            .focused($isFocused)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isFocused
                        ? Color(Color.appTeal).opacity(0.7)
                        : Color(Color.appTeal).opacity(0.15),
                        lineWidth: isFocused ? 1.8 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .foregroundColor(Color(red: 26/255, green: 47/255, blue: 63/255))
    }
}

struct PasswordField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .autocapitalization(.none)
            .autocorrectionDisabled()
            .focused($isFocused)

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundColor(Color.appNavy)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(Color.appLightTeal)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isFocused
                        ? Color(Color.appTeal).opacity(0.7)
                        : Color(Color.appTeal).opacity(0.15),
                    lineWidth: isFocused ? 1.8 : 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .foregroundColor(Color(red: 26/255, green: 47/255, blue: 63/255))
    }
}

struct AuthButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: 150)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color(Color.appTeal))
                        .opacity(isEnabled ? 1 : 0.5)
                )
        }
        .disabled(!isEnabled)
    }
}


