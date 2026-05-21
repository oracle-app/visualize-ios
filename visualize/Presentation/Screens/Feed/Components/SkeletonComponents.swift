//
//  SkeletonComponents.swift
//  visualize
//
//  Created by Carlos Amador on 20/05/26.
//

import SwiftUI

struct BlinkingSkeletonModifier: ViewModifier {
    @State private var isBlinking = false
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color.gray.opacity(0.20))
            .opacity(isBlinking ? 0.4 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isBlinking)
            .onAppear { isBlinking = true }
    }
}

extension View {
    func skeletonEffect() -> some View {
        self.modifier(BlinkingSkeletonModifier())
    }
}

struct SkeletonFeedCard: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(height: 17)
                        .skeletonEffect()
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 150, height: 13)
                        .skeletonEffect()
                }
                Spacer()
                Circle()
                    .frame(width: 37, height: 37)
                    .skeletonEffect()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .skeletonEffect()
                    .padding(15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(minHeight: 200)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 10))
            HStack(spacing: -20) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .frame(width: 33, height: 33)
                        .skeletonEffect()
                        .overlay(Circle().stroke(Color.appMint, lineWidth: 2))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
        }
        .padding(16)
        .background(Color.appMint)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
        .frame(height: 390)
        .padding(.bottom, 16)
    }
}

#Preview {
    SkeletonFeedCard()
}
