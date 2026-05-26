//
//  NotificationsViewModel.swift
//
// created by Miguel Degollado


import Foundation
import Combine
import SwiftUI

@MainActor
final class NotificationsViewModel: ObservableObject {

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

    @Published private(set) var state: NotificationsState = .loading
    private var pendingReadIDs: Set<String> = []

    // MARK: - Dependencies

    private let authRepository: AuthRepository
    private let getNotificationsUseCase: GetNotificationsUseCase
    private let markNotificationReadUseCase: MarkNotificationReadUseCase
    private let markAllNotificationsReadUseCase: MarkAllNotificationsReadUseCase
    private var listenerTask: Task<Void, Never>?

    // MARK: - Init
    // No convenience init — concrete dependencies injected from NavBar
    // to keep the ViewModel decoupled from data implementations.

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
    }

    deinit { listenerTask?.cancel() }

    // MARK: - Load

    func loadNotifications() {
        guard let userID = authRepository.getCurrentUser()?.uid else {
            print("[NotificationsVM] ❌ No authenticated user found")
            state = .empty
            return
        }
        print("[NotificationsVM] ✅ Loading for userID: \(userID)")
        state = .loading
        listenerTask?.cancel()
        listenerTask = Task {
            for await notifications in getNotificationsUseCase.execute(for: userID) {
                guard !Task.isCancelled else { break }
                print("[NotificationsVM] 📦 Received \(notifications.count) notifications from Firestore")
                let groups = group(notifications)
                let totalItems = groups.flatMap(\.items).count
                print("[NotificationsVM] 📁 Grouped into \(groups.count) sections, \(totalItems) total items")
                let corrected = applyPendingReads(to: groups)
                let newState = corrected.allSatisfy({ $0.items.isEmpty }) ? NotificationsState.empty : .loaded(corrected)
                print("[NotificationsVM] 🎯 Setting state: \(newState)")
                state = newState
            }
        }
    }
    // MARK: - Mark as read (single)

    func markAsRead(id: String) {
        guard let userID = authRepository.getCurrentUser()?.uid else { return }
        pendingReadIDs.insert(id)
        applyOptimisticRead(id: id)
        Task {
            try? await markNotificationReadUseCase.execute(notificationID: id, userID: userID)
            pendingReadIDs.remove(id)
        }
    }

    // MARK: - Mark all as read

    func markAllAsRead() {
        guard case .loaded(let groups) = state,
              let userID = authRepository.getCurrentUser()?.uid else { return }
        state = .loaded(groups.map { group in
            NotificationDisplayGroup(id: group.id, items: group.items.map {
                NotificationDisplayItem(id: $0.id, boldPrefix: $0.boldPrefix, message: $0.message,
                    timestamp: $0.timestamp, isRead: true,
                    avatarInitials: $0.avatarInitials, avatarColor: $0.avatarColor, avatarURL: $0.avatarURL)
            })
        })
        Task { try? await markAllNotificationsReadUseCase.execute(userID: userID) }
    }

    // MARK: - Grouping (moved from Repository per PR feedback)

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
