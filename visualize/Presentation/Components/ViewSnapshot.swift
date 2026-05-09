//
//  ViewSnapshot.swift
//  visualize
//
//  Created by Nicolas Peralta on 09/05/26.
//

import SwiftUI
import UIKit
import SciChart

// MARK: - ViewSnapshot

/// Off-screen snapshot helper for any SwiftUI `View`.
/// Attaches a `UIHostingController` to the active scene's `UIWindow`
/// outside visible bounds, forces layout, and captures via
/// `UIView.drawHierarchy(in:afterScreenUpdates:)`.
///
/// Sibling to `ScreenShotPrevention.swift` — where that helper controls
/// what is shown, this one captures what is shown.
@MainActor
enum ViewSnapshot {

    // MARK: - Public API

    /// Captures `content` off-screen at the given `size`.
    ///
    /// Returns `nil` if no foreground-active scene/window can be found
    /// or if `size` has a non-positive dimension.
    static func capture<Content: View>(
        _ content: Content,
        size: CGSize
    ) -> UIImage? {
        guard let window = activeWindow(),
              size.width > 0,
              size.height > 0 else {
            return nil
        }

        let host = UIHostingController(rootView: content)
        host.view.frame = CGRect(origin: .zero, size: size)
        host.view.backgroundColor = .clear

        // Attach outside visible bounds (off-screen right)
        host.view.frame.origin = CGPoint(x: window.bounds.width + 1000, y: 0)
        window.addSubview(host.view)
        host.view.layoutIfNeeded()

        defer { host.view.removeFromSuperview() }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
        }
    }

    // MARK: - Private Helpers

    /// Returns the active foreground `UIWindow` from connected scenes.
    /// Prefers the key window in a foreground-active scene; falls back
    /// to the first available window if none is found.
    private static func activeWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first
    }
}
