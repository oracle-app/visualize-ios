//
//  EmailSearchField.swift
//  Visualize
//
//  Created by Diana Escalante on 14/04/26.
//

import SwiftUI

/// A custom text field component used to search for teammates by their email addresses.
/// Includes visual focus states, an explicit clear button, and customized shadow effects.
struct EmailSearchFieldView: View {
    
    @Binding var email: String
    var onClear: () -> Void
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            
            Image(systemName: "magnifyingglass")
                .foregroundStyle(isFocused ? AppColors.Brand.primaryOrange : AppColors.Brand.teal)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            TextField(String(localized: "Enter email"), text: $email)
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textCase(nil)
                .keyboardType(.emailAddress)
                .foregroundStyle(AppColors.Text.primary)
            
            if !email.isEmpty {
                Button {
                    onClear()
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.gray.opacity(0.8))
                }
                .transition(.scale)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppColors.Brand.mint)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    isFocused
                    ? AppColors.Brand.primaryOrange
                    : Color.gray.opacity(0.25),
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .shadow(
            color: isFocused
                ? AppColors.Brand.primaryOrange.opacity(0.2)
                : Color.black.opacity(0.08),
            radius: isFocused ? 12 : 6,
            x: 0,
            y: 4
        )
    }
}
