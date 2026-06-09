//
//  FeedUITests.swift
//  VisualizeUITests
//
//  UI tests for FeedScreen.
//  Covers: FEED-002 (LoadingListView skeleton), FEED-013 (Toast verde 3s)
//
//  Requirements:
//  - The app must expose accessibility identifiers as documented below.
//  - Add these identifiers to your SwiftUI views:
//
//    LoadingListView  → .accessibilityIdentifier("loadingListView")
//    EmptyListView    → .accessibilityIdentifier("emptyListView")
//    ErrorListView    → .accessibilityIdentifier("errorListView")
//    LoadedListView   → .accessibilityIdentifier("loadedListView")
//    ToastView        → .accessibilityIdentifier("toastView")
//    FeedScreen root  → set a launch argument to inject a specific state,
//                       or use a dedicated UITest scheme that starts in the
//                       desired state (recommended: LaunchArgument flags).
//
//  LaunchArguments used in this file:
//    "-feedState loading"  → FeedScreen starts in .loading state
//    "-feedState loaded"   → FeedScreen starts in .loaded state with sample cards
//    "-triggerHide"        → automatically triggers hideVisualization after load
//                            so the toast appears without user interaction
//

import XCTest

final class FeedUITests: XCTestCase {

    var app: XCUIApplication!

    // MARK: - Setup / Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - FEED-002 | Estado de carga (loading skeleton)

    /// Verifies that LoadingListView is rendered while the feed is fetching data.
    ///
    /// Setup required in the app:
    ///   - When the launch argument "-feedState loading" is present, inject a
    ///     version of FeedScreenViewModel whose loadData() never resolves, keeping
    ///     the state in `.loading`. This can be done in your App entry point:
    ///
    ///       if CommandLine.arguments.contains("-feedState") {
    ///           // inject a SlowMockViewModel that stays in .loading
    ///       }
    ///
    func test_FEED002_loadingSkeleton_isVisibleWhileDataIsFetching() throws {
        // Arrange – launch the app in the permanent loading state
        app.launchArguments = ["-feedState", "loading"]
        app.launch()

        // Act – navigate to the Feed tab / screen if needed
        // (adjust identifier to match your TabView or initial NavigationStack)
        // app.tabBars.buttons["Feed"].tap()

        // Assert – LoadingListView must be visible
        let loadingView = app.otherElements["loadingListView"]
        XCTAssertTrue(
            loadingView.waitForExistence(timeout: 10),
            "LoadingListView (skeleton) should be visible while the feed is loading"
        )

        // Assert – loaded, empty, and error views must NOT be visible simultaneously
        XCTAssertFalse(app.otherElements["loadedListView"].exists,  "LoadedListView must not appear during loading")
        XCTAssertFalse(app.otherElements["emptyListView"].exists,   "EmptyListView must not appear during loading")
        XCTAssertFalse(app.otherElements["errorListView"].exists,   "ErrorListView must not appear during loading")
    }

    // MARK: - FEED-013 | Toast de éxito al ocultar

    /// Verifies that a green success toast appears after hiding a shared visualization
    /// and automatically disappears after ~3 seconds.
    ///
    /// Setup required in the app:
    ///   - When the launch argument "-feedState loaded" is present, pre-load the feed
    ///     with at least one shared card (authorID != currentUserID).
    ///   - When the launch argument "-triggerHide" is also present, automatically
    ///     call hideVisualization() on that card so the toast fires without needing
    ///     the test to navigate inside context menus.
    ///
    ///   Alternatively you can drive the hide action through the UI:
    ///     1. Long-press the card to open the context menu.
    ///     2. Tap the "Hide" action button.
    ///   In that case remove "-triggerHide" and uncomment the UI-driven steps below.
    ///
    func test_FEED013_successToast_isVisibleThenDisappearsAfterThreeSeconds() throws {
        // Arrange – launch with a loaded feed and auto-trigger a hide action
        app.launchArguments = ["-feedState", "loaded", "-triggerHide"]
        app.launch()

        // --- Option A: launch-argument-triggered hide (recommended) ---
        // The toast should appear automatically because the app triggers the hide.

        // --- Option B: UI-driven hide (uncomment if not using launch argument) ---
        // let firstCard = app.otherElements.matching(identifier: "feedCard").firstMatch
        // XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        // firstCard.press(forDuration: 1.0)           // open context menu
        // app.buttons["Hide"].tap()

        // Assert – toast becomes visible
        let toast = app.otherElements["toastView"]
        XCTAssertTrue(
            toast.waitForExistence(timeout: 5),
            "Success toast should appear after hiding a visualization"
        )

        // Assert – toast disappears automatically within 4 seconds (3s display + margin)
        let disappeared = toast.waitForNonExistence(timeout: 4)
        XCTAssertTrue(disappeared, "Toast should auto-dismiss after approximately 3 seconds")
    }
}
