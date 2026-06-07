//
//  SnipUITests.swift
//  visualizeUITests
//
//  Isolated screen-level UI tests for the Snipping Tool, driven by XCUIAutomation.
//
//  Test plan coverage:
//  - SNIP-001: Activating the snip tool presents SnipEditorScreen with the
//              chart image rendered (isolated scene, no backend dependency).
//  - SNIP-004: A snip is visible as a comment with the image attached
//              (isolated scene, no Firestore dependency).
//
//  Both tests rely on launch arguments handled by VisualizeApp under #if DEBUG:
//    -uitest-snip-editor    -> mounts SnipEditorScreen directly
//    -uitest-snip-comment   -> mounts SnipCommentSampleView directly
//
//  End-to-end flows (Feed -> FullScreen -> tap -> editor, and Firestore
//  round-trip for the snip comment) are validated through manual testing per
//  the test plan's Manual section.
//

import XCTest

final class SnipUITests: XCTestCase {

    override func setUpWithError() throws {
        // Fail fast: stop the whole test on first XCTAssert failure to avoid
        // chained false positives on UI elements that depend on earlier ones.
        continueAfterFailure = false
    }

    // MARK: - SNIP-001

    /// Verifies that the snip editor screen is presented when the snip tool is
    /// activated. In this isolated scene we launch directly into the editor;
    /// the production activation flow (FullScreen -> snip button tap) is covered
    /// by the manual section of the test plan.
    func test_SNIP001_snipEditorScreen_isPresentedWhenSnipToolActivated() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-snip-editor"]
        app.launch()

        let editor = app.otherElements["SnipEditorScreen"]
        XCTAssertTrue(
            editor.waitForExistence(timeout: 5),
            "SnipEditorScreen should be visible after launching with -uitest-snip-editor"
        )

        // The chart image is the core content of the editor — if it doesn't
        // render, the editor is effectively broken even if the container exists.
        let chartImage = app.images["SnipChartImage"]
        XCTAssertTrue(
            chartImage.waitForExistence(timeout: 2),
            "SnipChartImage should render inside the editor"
        )
    }

    // MARK: - SNIP-004

    /// Verifies that a snip rendered as a comment shows the attached image.
    /// The sample scene simulates the visual contract of a snip-comment row without
    /// requiring a Firestore round-trip.
    func test_SNIP004_snipIsVisibleAsCommentWithImageAttached() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-snip-comment"]
        app.launch()

        let snipImage = app.images["SnipCommentImage"]
        XCTAssertTrue(
            snipImage.waitForExistence(timeout: 5),
            "SnipCommentImage should be visible inside the comment row"
        )
        XCTAssertTrue(
            snipImage.isHittable,
            "SnipCommentImage should be on-screen (hittable), not clipped or hidden"
        )
    }
}
