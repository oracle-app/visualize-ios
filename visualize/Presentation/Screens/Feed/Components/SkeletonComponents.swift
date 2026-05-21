//
//  SkeletonComponents.swift
//  visualize
//
//  Created by Carlos Amador on 20/05/26.
//

import SwiftUI

// MARK: - Modificador de Parpadeo Animado
struct BlinkingSkeletonModifier: ViewModifier {
    @State private var isBlinking = false
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color.gray.opacity(0.20)) // Color base del esqueleto más sutil
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

// MARK: - Réplica de FeedCard (Skeleton)
struct SkeletonFeedCard: View {
    var body: some View {
        VStack(spacing: 12) {
            // 1. Cabecera (Título y Menú)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    // Simulación del Título (17pt semibold)
                    RoundedRectangle(cornerRadius: 4)
                        .frame(height: 17)
                        .skeletonEffect()
                    
                    // Simulación del Subtítulo (by author • date)
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 150, height: 13)
                        .skeletonEffect()
                }
                
                Spacer()
                
                // Simulación del botón de Menú (37x37)
                Circle()
                    .frame(width: 37, height: 37)
                    .skeletonEffect()
            }
            
            // 2. Área de la Gráfica (Caja blanca)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .skeletonEffect()
                    .padding(15) // Coincide con el padding de ChartRendererView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(minHeight: 200)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 10))
            
            // 3. Footer (Avatares compartidos)
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
        .padding(16) // Padding interno de la card
        .background(Color.appMint) // Mismo fondo que la FeedCard original
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20) // Margen externo
        .frame(height: 390) // Altura fija idéntica
        .padding(.bottom, 16)
    }
}

#Preview {
    SkeletonFeedCard()
}
