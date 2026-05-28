//
//  NotificationsGroup.swift
//  visualize
//
//  Groups Notification domain items under a labeled time period
//  (e.g. "Today", "Yesterday", "Last 30 days").
//  Updated to use Notification instead of the legacy NotificationItem.
//

import Foundation

struct NotificationsGroup: Identifiable {
    let id: String
    let notifications: [Notification]
    var title: String { id }
}
