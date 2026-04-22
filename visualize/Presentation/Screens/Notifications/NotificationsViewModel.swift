//
//  NotificationsViewModel.swift
//  visualize
//
//  Created by Miguel Degollado Ramirez on 22/04/26.

import Foundation


final class NotificationsViewModel: ObservableObject {

    // MARK: - State

    enum NotificationsState: Equatable {
        case loading
        case loaded([NotificationsGroup])
        case empty
        case error(String)

        static func == (lhs: NotificationsState, rhs: NotificationsState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading): return true
            case (.empty, .empty): return true
            case (.error(let a), .error(let b)): return a == b
            case (.loaded(let a), .loaded(let b)):
                return a.map(\.id) == b.map(\.id)
            default: return false
            }
        }
    }

    @Published private(set) var state: NotificationsState = .loading

    // MARK: - Init

    init() {}

    // MARK: - Public API

    func loadNotifications() {
        state = .loading

        // TODO: Replace with actual GetNotificationsUseCase call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }

            let now = Date()

            let todayItems: [Notification] = [
                Notification(id: "n1", userID: "u1", isRead: false, type: "generic",      createdAt: now),
                Notification(id: "n2", userID: "u1", isRead: false, type: "generic",      createdAt: now.addingTimeInterval(-1_200)),
                Notification(id: "n3", userID: "u1", isRead: false, type: "thread_reply", createdAt: now.addingTimeInterval(-3_600)),
                Notification(id: "n4", userID: "u1", isRead: false, type: "thread_reply", createdAt: now.addingTimeInterval(-14_400))
            ]

            let yesterdayItems: [Notification] = [
                Notification(id: "n5", userID: "u1", isRead: false, type: "thread_reply", createdAt: now.addingTimeInterval(-86_400)),
                Notification(id: "n6", userID: "u1", isRead: true,  type: "team_invite",  createdAt: now.addingTimeInterval(-86_400))
            ]

            let last30DaysItems: [Notification] = [
                Notification(id: "n7", userID: "u1", isRead: true, type: "chart_shared",  createdAt: now.addingTimeInterval(-432_000)),
                Notification(id: "n8", userID: "u1", isRead: true, type: "thread_reply",  createdAt: now.addingTimeInterval(-1_555_200))
            ]

            let groups: [NotificationsGroup] = [
                NotificationsGroup(
                    id: NSLocalizedString("notifications.section.today", comment: ""),
                    notifications: todayItems
                ),
                NotificationsGroup(
                    id: NSLocalizedString("notifications.section.yesterday", comment: ""),
                    notifications: yesterdayItems
                ),
                NotificationsGroup(
                    id: NSLocalizedString("notifications.section.last30days", comment: ""),
                    notifications: last30DaysItems
                )
            ]

            let allEmpty = groups.allSatisfy { $0.notifications.isEmpty }
            self.state = allEmpty ? .empty : .loaded(groups)
        }
    }

    func markAsRead(id: String) {
        guard case .loaded(let groups) = state else { return }

        let updated = groups.map { group in
            let updatedNotifications = group.notifications.map { item in
                item.id == id
                    ? Notification(
                        id: item.id,
                        userID: item.userID,
                        isRead: true,
                        type: item.type,
                        createdAt: item.createdAt
                      )
                    : item
            }
            return NotificationsGroup(id: group.id, notifications: updatedNotifications)
        }

        state = .loaded(updated)
    }
}
