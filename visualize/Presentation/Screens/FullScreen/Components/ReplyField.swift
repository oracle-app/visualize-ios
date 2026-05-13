//
//  ReplyField.swift
//  visualize
//
//  Created by Kimberly Marquez on 4/28/26.
//
import SwiftUI

struct ReplyField: View {
    @Binding var text: String
    var isActive: Bool = false
    var onSend: () -> Void = {}
    
    @FocusState private var focused: Bool
    
    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        HStack(spacing: 12){
            
            HStack {
                TextField("Reply . . .", text: $text)
                    .foregroundStyle(.black)
                    .font(.system(size: 20))
                    .focused($focused)
                
                Spacer()
                
                Button{
                    //Microfone
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
            
            
            if hasText {
                Button{
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
                .transition(.scale.combined(with: .opacity))
            }
            
        }
        .padding()
        .animation(.easeInOut(duration: 0.2), value: hasText)
        .onChange(of: isActive) {_, newValue in
            focused = newValue
        }
    }
}
#Preview {
    ReplyField(text: .constant(""))
}
