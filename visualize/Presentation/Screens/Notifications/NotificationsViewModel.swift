//
//  NotificationsViewModel.swift
//  visualize
//
// Created By Miguel Degollado

import Foundation
import SwiftUI

@MainActor
@Observable
final class NotificationsViewModel {

    // MARK: - State

    enum NotificationsState: Equatable {
        case loading
        case loaded([NotificationDisplayGroup])
        case empty
        case error(String)

        static func == (lhs: NotificationsState, rhs: NotificationsState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading), (.empty, .empty): return true
            case (.error(let a), .error(let b)):         return a == b
            case (.loaded(let a), .loaded(let b)):       return a.map(\.id) == b.map(\.id)
            default:                                     return false
            }
        }
    }

    private(set) var state: NotificationsState = .loading
    private var pendingReadIDs: Set<String> = []

    // MARK: - Dependencies

    private let authRepository: AuthRepository
    private let getNotificationsUseCase: GetNotificationsUseCase
    private let markNotificationReadUseCase: MarkNotificationReadUseCase
    private let markAllNotificationsReadUseCase: MarkAllNotificationsReadUseCase
    private(set) var currentUserID: String = ""
    private let listenerBox = TaskBox()

    // MARK: - Init

    init(
        authRepository: AuthRepository,
        getNotificationsUseCase: GetNotificationsUseCase,
        markNotificationReadUseCase: MarkNotificationReadUseCase,
        markAllNotificationsReadUseCase: MarkAllNotificationsReadUseCase
    ) {
        self.authRepository = authRepository
        self.getNotificationsUseCase = getNotificationsUseCase
        self.markNotificationReadUseCase = markNotificationReadUseCase
        self.markAllNotificationsReadUseCase = markAllNotificationsReadUseCase
        Task {
            await initializeUser()
        }
    }
    
    private func initializeUser() async {
        do {
            self.currentUserID = try await authRepository.getCurrentUserID()
            self.loadNotifications()
        } catch {
            self.state = .error("Could not authenticate user")
        }
    }

    // MARK: - Load

    func loadNotifications() {
        guard !currentUserID.isEmpty else {
            return
        }

        state = .loading
        listenerBox.task?.cancel()
        listenerBox.task = Task {
            for await notifications in getNotificationsUseCase.execute(for: currentUserID) {
                guard !Task.isCancelled else { break }
                let groups = group(notifications)
                let corrected = applyPendingReads(to: groups)
                state = corrected.allSatisfy({ $0.items.isEmpty }) ? .empty : .loaded(corrected)
            }
        }
    }

    // MARK: - Mark as read

    func markAsRead(id: String) {
        pendingReadIDs.insert(id)
        applyOptimisticRead(id: id)
        Task {
            try? await markNotificationReadUseCase.execute(notificationID: id)
            pendingReadIDs.remove(id)
        }
    }

    func markAllAsRead() {
        guard case .loaded(let groups) = state,
              !currentUserID.isEmpty else { return }
              
        state = .loaded(groups.map { group in
            NotificationDisplayGroup(id: group.id, items: group.items.map {
                NotificationDisplayItem(id: $0.id, boldPrefix: $0.boldPrefix, message: $0.message,
                    timestamp: $0.timestamp, isRead: true,
                    avatarInitials: $0.avatarInitials, avatarColor: $0.avatarColor, avatarURL: $0.avatarURL)
            })
        })
        
        Task { try? await markAllNotificationsReadUseCase.execute(userID: currentUserID) }
    }

    // MARK: - Grouping

    private func group(_ notifications: [Notification]) -> [NotificationDisplayGroup] {
        let calendar = Calendar.current
        let now = Date()
        var today:     [NotificationDisplayItem] = []
        var yesterday: [NotificationDisplayItem] = []
        var last30:    [NotificationDisplayItem] = []

        for notification in notifications {
            let item = notification.toDisplayItem()
            if calendar.isDateInToday(notification.createdAt) {
                today.append(item)
            } else if calendar.isDateInYesterday(notification.createdAt) {
                yesterday.append(item)
            } else if let days = calendar.dateComponents([.day], from: notification.createdAt, to: now).day,
                      days <= 30 {
                last30.append(item)
            }
        }

        return [
            NotificationDisplayGroup(id: "Today",        items: today),
            NotificationDisplayGroup(id: "Yesterday",    items: yesterday),
            NotificationDisplayGroup(id: "Last 30 days", items: last30)
        ]
    }

    // MARK: - Optimistic helpers

    private func applyPendingReads(to groups: [NotificationDisplayGroup]) -> [NotificationDisplayGroup] {
        guard !pendingReadIDs.isEmpty else { return groups }
        return groups.map { group in
            NotificationDisplayGroup(id: group.id, items: group.items.map { item in
                guard pendingReadIDs.contains(item.id) else { return item }
                return NotificationDisplayItem(id: item.id, boldPrefix: item.boldPrefix, message: item.message,
                    timestamp: item.timestamp, isRead: true,
                    avatarInitials: item.avatarInitials, avatarColor: item.avatarColor, avatarURL: item.avatarURL)
            })
        }
    }

    private func applyOptimisticRead(id: String) {
        guard case .loaded(let groups) = state else { return }
        state = .loaded(groups.map { group in
            NotificationDisplayGroup(id: group.id, items: group.items.map { item in
                guard item.id == id else { return item }
                return NotificationDisplayItem(id: item.id, boldPrefix: item.boldPrefix, message: item.message,
                    timestamp: item.timestamp, isRead: true,
                    avatarInitials: item.avatarInitials, avatarColor: item.avatarColor, avatarURL: item.avatarURL)
            })
        })
    }

    // MARK: - Testing only

    #if DEBUG
    func forceState(_ newState: NotificationsState) {
        state = newState
    }
    #endif
}

private final class TaskBox: @unchecked Sendable {
    var task: Task<Void, Never>?
    deinit { task?.cancel() }
}
