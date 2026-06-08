//
//  AuthComponents.swift
//  VisualizeApp
//
//  Created by Libia Fv on 19/04/26.
//

import SwiftUI

// MARK: - Input Field

/// Reusable text input component used across
/// authentication screens.
///
/// Features:
/// - Dynamic error styling
/// - Focus state styling
/// - Custom keyboard type
/// - Inline validation message
struct InputField: View {
    
    // MARK: - Properties
    
    let placeholder: String
    
    @Binding var text: String
    
    /// Optional validation error message.
    var errorMessage: String?
    
    /// Keyboard configuration depending on input type.
    var keyboardType: UIKeyboardType = .default
    
    /// Tracks focus state for UI feedback.
    @FocusState private var isFocused: Bool
    
    // MARK: - Computed Properties
    
    /// Determines whether the field
    /// is currently displaying an error state.
    private var hasError: Bool {
        errorMessage != nil && !errorMessage!.isEmpty
    }

    // MARK: - Body
    
    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundStyle(
                    hasError ? AppColors.Status.red : Color.gray.opacity(0.8)
                )
        )
        .keyboardType(keyboardType)
        .autocapitalization(.none)
        .autocorrectionDisabled()
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .focused($isFocused)
        .background(
            hasError ? AppColors.UI.authErrorBackground : AppColors.Brand.mint
        )
        .foregroundStyle(AppColors.Text.authFieldText)
        .tint(hasError ? AppColors.Status.red : AppColors.Brand.teal)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    hasError
                    ? AppColors.Status.red
                    : (
                        isFocused
                        ? AppColors.Brand.teal.opacity(0.7)
                        : AppColors.Brand.teal.opacity(0.15)
                    ),
                    lineWidth: isFocused || hasError ? 1.8 : 1
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
                .animation(.easeInOut(duration: 0.2), value: hasError)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .bottomLeading) {
            Text(errorMessage ?? "")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.Status.red)
                .opacity(hasError ? 1 : 0)
                .offset(x: 8, y: 19)
        }
    }
}

// MARK: - Password Field

/// Reusable secure input component for passwords.
///
/// Features:
/// - Password visibility toggle
/// - Dynamic validation styling
/// - Focus state feedback
/// - Inline validation message
struct PasswordField: View {
    
    // MARK: - Properties
    
    let placeholder: String
    
    @Binding var text: String
    
    /// Controls password visibility state.
    @Binding var isVisible: Bool
    
    /// Optional validation error message.
    var errorMessage: String?
    
    /// Tracks focus state for UI feedback.
    @FocusState private var isFocused: Bool
    
    // MARK: - Computed Properties
    
    /// Determines whether the field
    /// is currently displaying an error state.
    private var hasError: Bool {
        errorMessage != nil && !errorMessage!.isEmpty
    }

    // MARK: - Body
    
    var body: some View {
        HStack {
            
            // MARK: Password Input
            
            ZStack {
                SecureField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .foregroundStyle(
                            hasError ? AppColors.Status.red : Color.gray.opacity(0.8)
                        )
                )
                .opacity(isVisible ? 0 : 1)
                
                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .foregroundStyle(
                            hasError ? AppColors.Status.red : Color.gray.opacity(0.8)
                        )
                )
                .opacity(isVisible ? 1 : 0)
            }
            .autocapitalization(.none)
            .autocorrectionDisabled()
            .focused($isFocused)
            .foregroundStyle(AppColors.Text.authFieldText)
            .tint(hasError ? AppColors.Status.red : AppColors.Brand.teal)

            // MARK: Visibility Toggle
            
            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundStyle(AppColors.UI.authButtonIcon)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(
            hasError ? AppColors.UI.authErrorBackground : AppColors.Brand.mint
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    hasError
                    ? AppColors.Status.red
                    : (
                        isFocused
                        ? AppColors.Brand.teal.opacity(0.7)
                        : AppColors.Brand.teal.opacity(0.15)
                    ),
                    lineWidth: isFocused || hasError ? 1.8 : 1
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
                .animation(.easeInOut(duration: 0.2), value: hasError)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .bottomLeading) {
            Text(errorMessage ?? "")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.Status.red)
                .opacity(hasError ? 1 : 0)
                .offset(x: 8, y: 19)
        }
    }
}

// MARK: - Authentication Button

/// Reusable button component used in
/// authentication-related screens.
///
/// Used for:
/// - Sign up
/// - Login
/// - Authentication actions
struct AuthButton: View {
    
    // MARK: - Properties
    
    let title: String
    let action: () -> Void

    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.Text.authButtonText)
                .frame(maxWidth: 150)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(AppColors.Text.tertiary)
                )
        }
    }
}
