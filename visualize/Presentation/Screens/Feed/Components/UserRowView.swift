//
//  UserRowView.swift
//  Visualize
//
//  Created by Diana Escalante on 14/04/26.
//

//
// A row component that displays basic user information (name and email).
// Optionally includes a remove button with a tap animation.
// Designed to be reusable in lists, dropdowns, or selection views.
//

import SwiftUI

struct UserRowView: View {
    
    let user: AppUser
    var onRemove: (() -> Void)? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .font(.body.weight(.bold))
                    .foregroundStyle(Color.primaryText)
                
                Text(user.email)
                    .font(.subheadline)
                .foregroundStyle(Color.primaryText)
                .opacity(0.5)
            }
            
            Spacer()
            
            if let onRemove {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isPressed = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isPressed = false
                        }
                        onRemove()
                    }
                    
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(Color(.systemRed))
                        .scaleEffect(isPressed ? 0.8 : 1)
                        .opacity(isPressed ? 0.6 : 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
    }
}
