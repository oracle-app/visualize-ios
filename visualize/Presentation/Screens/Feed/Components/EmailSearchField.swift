import SwiftUI

struct EmailSearchField: View {
    
    @Binding var email: String
    var onClear: () -> Void
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            
            Image(systemName: "magnifyingglass")
                .foregroundStyle(isFocused ? Color.primaryOrange : Color.primaryBlue)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            TextField("Enter email", text: $email)
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textCase(nil)
                .keyboardType(.emailAddress)
                .foregroundStyle(Color.primaryText)
            
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
                    .fill(Color(red: 230/255, green: 237/255, blue: 236/255).opacity(0.4))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    isFocused
                    ? Color.primaryOrange
                    : Color.gray.opacity(0.25),
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .shadow(
            color: isFocused
                ? Color.primaryOrange.opacity(0.2)
                : Color.black.opacity(0.08),
            radius: isFocused ? 12 : 6,
            x: 0,
            y: 4
        )
    }
}
