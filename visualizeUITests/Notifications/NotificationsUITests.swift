//
//  NotificationsUITests.swift
//  visualize
//
//  Created by Rubén Castro on 07/06/26.
//
//  Isolated UI tests for the Notifications screen states required by the
//  notification test plan.
//

import XCTest

final class NotificationsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - NOTI-001

    /// Verifies that grouped notifications are visible in the notifications UI.
    /// The isolated scene avoids Firebase/backend dependencies while still
    /// exercising the NotificationGroupCardView rendering path.
    func test_NOTI001_notificationsListShowsGroupedNotifications() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-notifications-loaded"]
        app.launch()

        XCTAssertTrue(
            app.staticTexts["Notifications"].waitForExistence(timeout: 5),
            "Notifications title should be visible."
        )
        XCTAssertTrue(app.staticTexts["Today"].exists, "Today group should be visible.")
        XCTAssertTrue(app.staticTexts["Yesterday"].exists, "Yesterday group should be visible.")
        XCTAssertTrue(
            app.staticTexts["Nico commented on your visualization."].exists,
            "The first grouped notification should be visible."
        )
        XCTAssertTrue(
            app.staticTexts["Ana shared a visualization with you."].exists,
            "The second grouped notification should be visible."
        )
        XCTAssertTrue(
            app.staticTexts["No more notifications."].exists,
            "The loaded state footer should be visible."
        )
    }

    // MARK: - NOTI-002

    /// Verifies that the empty state is rendered when there are no notifications.
    func test_NOTI002_notificationsEmptyStateIsVisible() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-notifications-empty"]
        app.launch()

        XCTAssertTrue(
            app.staticTexts["No notifications yet"].waitForExistence(timeout: 5),
            "NotificationsEmptyView title should be visible."
        )
        XCTAssertTrue(
            app.staticTexts["We'll notify you when there's something new."].exists,
            "NotificationsEmptyView message should be visible."
        )
    }
}
