//
//  NavigationBarAppearanceModifier.swift
//  visualize
//
//  No longer needed — navigation bar styling is handled natively
//  via .toolbarBackground(.ultraThinMaterial) and .tint() in NotificationsScreen.
//  This file is kept as an empty extension to avoid breaking existing references.
//

import SwiftUI

extension View {
    /// No-op — styling now done via native SwiftUI toolbar modifiers.
    func notificationsNavigationBarStyle() -> some View {
        self
    }
}
