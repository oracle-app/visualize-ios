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
///
/// Attaches a `UIHostingController` to the active scene's `UIWindow` outside
/// visible bounds, lets the GPU pipeline complete its first frame, then captures
/// via `UIView.drawHierarchy(in:afterScreenUpdates:)`.
///
/// Sibling to `ScreenShotPrevention.swift` — where that helper controls
/// what is shown, this one captures what is shown.
///
/// ### Why the warmup delay
///
/// Charts in this project use SciChart's `SCIChartSurface`, a Metal-backed
/// `UIViewRepresentable`. After `layoutIfNeeded`, the SwiftUI hierarchy is
/// positioned but the GPU has not yet presented its first frame to the
/// `CALayer`. A synchronous `drawHierarchy` would capture an empty layer
/// (blank image). The `warmupNanos` delay yields the main actor long enough
/// for Metal to submit and present the first frame.
///
/// `ImageRenderer` is NOT a substitute: it snapshots the SwiftUI render tree,
/// which does not contain SciChart's UIKit/Metal layers.
@MainActor
enum ViewSnapshot {

    // MARK: - Public API

    /// Captures `content` off-screen at the given `size`.
    ///
    /// Yields the main actor for `warmupNanos` between layout and capture so
    /// that `UIViewRepresentable` content backed by GPU pipelines (e.g.
    /// SciChart) can present its first frame before `drawHierarchy` runs.
    ///
    /// - Parameters:
    ///   - content: Any SwiftUI view. The view is rendered into a temporary
    ///     `UIHostingController` attached off-screen.
    ///   - size: Target render size in points. Must be strictly positive.
    ///   - warmupNanos: Time to yield between `layoutIfNeeded` and
    ///     `drawHierarchy`. Default 400ms — empirically sufficient for SciChart
    ///     scatter/line/bar/pie/donut on modern devices. Increase if captures
    ///     come back blank or partial on slower devices or larger datasets.
    /// - Returns: A captured `UIImage`, or `nil` if no foreground-active
    ///   window is available or `size` has a non-positive dimension.
    static func capture<Content: View>(
        _ content: Content,
        size: CGSize,
        warmupNanos: UInt64 = 400_000_000
    ) async -> UIImage? {
        guard let window = activeWindow(),
              size.width > 0,
              size.height > 0 else {
            return nil
        }

        let host = UIHostingController(rootView: content)
        host.view.frame = CGRect(origin: .zero, size: size)
        host.view.backgroundColor = .clear
        host.view.frame.origin = CGPoint(x: window.bounds.width + 1000, y: 0)
        window.addSubview(host.view)
        host.view.layoutIfNeeded()

        defer { host.view.removeFromSuperview() }

        // Let SwiftUI commit + GPU pipeline (e.g. SciChart Metal) submit and present.
        try? await Task.sleep(nanoseconds: warmupNanos)

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
