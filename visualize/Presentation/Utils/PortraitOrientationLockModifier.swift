//
//  PortraitOrientationLockModifier.swift
//  visualize
//
//  Created by Carlos Amador on 25/05/26.
//

import SwiftUI

struct PortraitOrientationLockModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                AppDelegate.orientationLock = .portrait
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                }
            }
            .onDisappear {
                AppDelegate.orientationLock = .all
            }
    }
}

extension View {
    func portraitOrientationLock() -> some View {
        self.modifier(PortraitOrientationLockModifier())
    }
}
