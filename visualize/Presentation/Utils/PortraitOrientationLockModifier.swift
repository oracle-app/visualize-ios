//
//  PortraitOrientationLockModifier.swift
//  visualize
//
//  Created by Carlos Amador on 25/05/26.
//

import SwiftUI

struct PortraitOrientationLockModifier: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard isEnabled else { return }
                AppDelegate.orientationLock = .portrait
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                }
            }
            .onDisappear {
                AppDelegate.orientationLock = .all
            }
            .onChange(of: isEnabled) { _, enabled in
                if enabled {
                    AppDelegate.orientationLock = .portrait
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                    }
                } else {
                    AppDelegate.orientationLock = .all
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .all))
                    }
                }
            }
    }
}

extension View {
    func portraitOrientationLock(_ isEnabled: Bool = true) -> some View {
        self.modifier(PortraitOrientationLockModifier(isEnabled: isEnabled))
    }
}
