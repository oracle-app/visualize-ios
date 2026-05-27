//
//  GenerateVisButton.swift
//  Visualize
//
//  Created by Libia Fv on 14/04/26.
//
// Description:
// Primary button for generating visualizations from the uploaded dataset.
// Triggers an external action when tapped.
// Features a capsule-shaped design with a color gradient and animated shimmer effect.
// Includes a continuous animation for visual emphasis.
// Uses shadows and borders to enhance depth and visibility.
// Represents the final action in the data upload and preparation flow.

import SwiftUI

struct GenerateVisButton: View {
    @State private var shimmerOffset: CGFloat = -200
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 14/255, green: 172/255, blue: 200/255),
                        Color(red: 235/255, green: 150/255, blue: 50/255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.12),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 160)
                .offset(x: shimmerOffset)
                .blendMode(.screen)
                
                Text(String(localized:"Generate visualizations"))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.9), lineWidth: 1.5))
//            .shadow(color: Color(red: 52/255, green: 121/255, blue: 124/255).opacity(0.5), radius: 8, x: 0, y: 0)
//            .shadow(color: Color(red: 180/255, green: 140/255, blue: 80/255).opacity(0.3), radius: 16, x: 0, y: 0)
//            .shadow(color: Color(red: 52/255, green: 121/255, blue: 124/255).opacity(0.15), radius: 28, x: 0, y: 0)
            .shadow(color: Color(red: 123/255, green: 212/255, blue: 208/255).opacity(1), radius: 4, x:1, y:1)
        }
        .onAppear {
            withAnimation(
                .linear(duration: 2.4)
                .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 400
            }
        }
    }
}

