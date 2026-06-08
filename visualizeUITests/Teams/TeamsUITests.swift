//
//  TeamsUITests.swift
//  visualize
//
//  Created by Diana Escalante on 07/06/26.
//

import XCTest

///  Isolated screen-level UI tests for the Teams screen, driven by XCUIAutomation.
///
///  Test plan coverage:
///  - TEAM-007: The teams list is visible (TeamsToggleListView style) with team rows rendered (isolated scene, no Firestore dependency).
///
///  Relies on a launch argument handled by VisualizeApp under #if DEBUG:
///    -uitest-teams-list  -> mounts TeamsScreen directly with MockTeamRepository and MockAuthRepository, so the list is populated.
///
///  End-to-end behavior (real Firestore round-trip, swipe-to-edit/delete, etc.) is validated through manual testing per the test plan's Manual section.

final class TeamsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Fail fast: stop on first XCTAssert failure to avoid chained false
        // positives on UI elements that depend on earlier ones.
        continueAfterFailure = false
    }

    // MARK: - TEAM-007

    /// Verifies that the teams list renders with at least one team row visible
    /// when the user belongs to or owns teams. The isolated scene seeds two
    /// teams via MockTeamRepository, so we expect both "My teams" and
    /// "Teams I'm in" sections to populate.
    func test_TEAM007_teamsList_isVisibleWithTeamRows() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-teams-list"]
        app.launch()

        // Section header from TeamsScreen.
        let myTeamsHeader = app.staticTexts["My teams"]
        XCTAssertTrue(
            myTeamsHeader.waitForExistence(timeout: 5),
            "'My teams' section header should be visible after launching with -uitest-teams-list"
        )

        // One of the mocked team names from MockTeamRepository.
        let mockedTeamRow = app.staticTexts["Design Team"]
        XCTAssertTrue(
            mockedTeamRow.waitForExistence(timeout: 2),
            "A mocked team row ('Design Team') should be rendered inside the list"
        )
        XCTAssertTrue(
            mockedTeamRow.isHittable,
            "The team row should be on-screen (hittable), not clipped or hidden"
        )

        // "Teams I'm in" section should also populate from MockTeamRepository.
        let joinedHeader = app.staticTexts["Teams I'm in"]
        XCTAssertTrue(
            joinedHeader.waitForExistence(timeout: 2),
            "'Teams I'm in' section header should be visible"
        )
    }
}
