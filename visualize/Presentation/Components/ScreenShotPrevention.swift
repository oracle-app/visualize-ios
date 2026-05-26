//
//  ScreenShotPrevention.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 28/04/26.
//
import Foundation
import SwiftUI

struct ScreenShotPreventer: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UITextField()
        view.isSecureTextEntry = true
        view.text = ""
        view.isUserInteractionEnabled = false
        
        if let autoHideLayer = findAutoHideLayer(view: view) {
            autoHideLayer.backgroundColor = UIColor.white.cgColor
        } else {
            /// Fall Back
            view.layer.sublayers?.last?.backgroundColor = UIColor.white.cgColor
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    func findAutoHideLayer(view: UIView) -> CALayer? {
        if let layers = view.layer.sublayers {
            if let layer = layers.first(where: { layer in
                layer.delegate.debugDescription.contains("UITextLayoutCanvasView")
            }) {
                return layer
            }
        }
        return nil
    }
}

// MARK: - Modifier
// MARK: - Modifier actualizado
struct ScreenShotPreventerModifier: ViewModifier {
    var isActive: Bool = true

    func body(content: Content) -> some View {
        if isActive {
            content
                .mask {
                    ScreenShotPreventer()
                        .ignoresSafeArea()
                }
                .background {
                    ContentUnavailableView(
                        "Not Allowed",
                        systemImage: "iphone.slash",
                        description: Text("Taking screenshots is not allowed for security reasons")
                    )
                }
        } else {
            content
        }
    }
}


// MARK: - Extension
extension View {
    func preventScreenShot(isActive: Bool = true) -> some View {
        self.modifier(ScreenShotPreventerModifier(isActive: isActive))
    }
}
