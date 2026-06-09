//
//  ProfileUITests.swift
//  visualize
//
//  Created by Mariana Islas Mondragón on 07/06/26.
//

import XCTest

/// Isolated screen-level UI tests for the Profile screen, driven by XCUIAutomation.
///
/// Test plan coverage:
/// - PROF-001A: The profile avatar is visible (fallback initial shown when no photo is set).
/// - PROF-001B: The profile username and email are visible below the avatar.
/// - PROF-003: The camera flow presents EditProfilePhotoView and dismisses it after saving.
///             Upload correctness is covered by UploadProfilePhotoUseCaseTests (unit).
///             Visual confirmation that the uploaded photo renders is covered by manual testing.
///
/// Relies on launch arguments handled by VisualizeApp under #if DEBUG:
///   -uitest-profile        -> mounts ProfileScreen directly with mock repositories so user data is pre-populated.
///   -uitest-camera-photo   -> injects a bundled test image as if the camera had returned it, bypassing AVCaptureSession
///                            (unavailable in the simulator). Sets pendingImage and showImageEditor = true on appear.
///
/// End-to-end behavior (real Firebase round-trip, photo library picker, delete confirmation, etc.)
/// is validated through manual testing per the test plan's Manual section.

final class ProfileUITests: XCTestCase {

    override func setUpWithError() throws {
        // Fail fast: stop on first XCTAssert failure to avoid chained false
        // positives on UI elements that depend on earlier ones.
        continueAfterFailure = false
    }

    // MARK: - PROF-001A

    /// Verifies that the profile avatar slot is visible on the profile screen.
    /// When no profile picture URL is set, ProfileHeaderView renders a fallback
    /// circle with the user's initial.
    func test_PROF001A_profileAvatar_isVisible() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-profile"]
        app.launch()

        let avatar = app.descendants(matching: .any)["ProfileAvatarFallback"]
        XCTAssertTrue(
            avatar.waitForExistence(timeout: 5),
            "Fallback avatar should be visible when no profile picture URL is set"
        )
    }

    // MARK: - PROF-001B

    /// Verifies that the username and email labels are rendered below the avatar.
    /// Both are seeded by the mock repository injected via -uitest-profile.
    func test_PROF001B_profileUserInfo_isVisible() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-profile"]
        app.launch()

        let username = app.staticTexts["ProfileUsername"]
        XCTAssertTrue(
            username.waitForExistence(timeout: 5),
            "Username should be visible below the avatar"
        )

        let email = app.staticTexts["ProfileEmail"]
        XCTAssertTrue(
            email.waitForExistence(timeout: 5),
            "Email should be visible below the username"
        )
    }

    // MARK: - PROF-003

    /// Verifies the camera flow UI: EditProfilePhotoView presents with the injected
    /// image and dismisses correctly after tapping Choose.
    ///
    /// Upload correctness (Storage write + Firestore URL update) is covered by
    /// UploadProfilePhotoUseCaseTests. Visual confirmation that the uploaded photo
    /// renders in the avatar is covered by manual testing, since AsyncImage cannot
    /// resolve a mock URL in the simulator.
    func test_PROF003_cameraFlow_editorPresentsAndDismisses() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-profile", "-uitest-camera-photo"]
        app.launch()

        let saveButton = app.buttons["SavePhotoButton"]
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 5),
            "EditProfilePhotoView should be presented with the injected camera image"
        )

        saveButton.tap()

        XCTAssertFalse(
            saveButton.waitForExistence(timeout: 3),
            "Editor should have dismissed after saving, confirming the upload flow completed"
        )
    }
}
