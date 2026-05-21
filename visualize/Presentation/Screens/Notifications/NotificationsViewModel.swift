//
//  NotificationsViewModel.swift
//  visualize
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class NotificationsViewModel: ObservableObject {
    
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
    
    private let getNotificationsUseCase: GetNotificationsUseCase
    private let markNotificationReadUseCase: MarkNotificationReadUseCase
    private let markAllNotificationsReadUseCase: MarkAllNotificationsReadUseCase
    private let deleteNotificationUseCase: DeleteNotificationUseCase
    private var listenerTask: Task<Void, Never>?
    
    init(
        getNotificationsUseCase: GetNotificationsUseCase,
        markNotificationReadUseCase: MarkNotificationReadUseCase,
        markAllNotificationsReadUseCase: MarkAllNotificationsReadUseCase,
        deleteNotificationUseCase: DeleteNotificationUseCase
    ) {
        self.getNotificationsUseCase = getNotificationsUseCase
        self.markNotificationReadUseCase = markNotificationReadUseCase
        self.markAllNotificationsReadUseCase = markAllNotificationsReadUseCase
        self.deleteNotificationUseCase = deleteNotificationUseCase
    }
    
    convenience init() {
        let repo = NotificationRepositoryImpl()
        self.init(
            getNotificationsUseCase: GetNotificationsUseCase(repository: repo),
            markNotificationReadUseCase: MarkNotificationReadUseCase(repository: repo),
            markAllNotificationsReadUseCase: MarkAllNotificationsReadUseCase(repository: repo),
            deleteNotificationUseCase: DeleteNotificationUseCase(repository: repo)
        )
    }
    
    deinit { listenerTask?.cancel() }
    
    func loadNotifications() {
        guard let userID = Auth.auth().currentUser?.uid else { state = .empty; return }
        state = .loading
        listenerTask?.cancel()
        listenerTask = Task {
            for await groups in getNotificationsUseCase.execute(for: userID) {
                guard !Task.isCancelled else { break }
                let total = groups.flatMap(\.items).count
                print("🔔 [Notifications] Snapshot recibido — \(total) notificaciones")
                groups.forEach { group in
                    print("  📁 \(group.id): \(group.items.count) items")
                }
                let corrected = applyPendingReads(to: groups)
                state = corrected.allSatisfy({ $0.items.isEmpty }) ? .empty : .loaded(corrected)
            }
        }
    }
    
    func markAsRead(id: String) {
        pendingReadIDs.insert(id)
        applyOptimisticRead(id: id)
        guard let userID = Auth.auth().currentUser?.uid else { pendingReadIDs.remove(id); return }
        Task {
            try? await markNotificationReadUseCase.execute(notificationID: id, userID: userID)
            pendingReadIDs.remove(id)
        }
    }
    
    func markAllAsRead() {
        guard case .loaded(let groups) = state else { return }
        state = .loaded(groups.map { group in
            NotificationDisplayGroup(id: group.id, items: group.items.map {
                NotificationDisplayItem(id: $0.id, boldPrefix: $0.boldPrefix, message: $0.message,
                                        timestamp: $0.timestamp, isRead: true,
                                        avatarInitials: $0.avatarInitials, avatarColor: $0.avatarColor, avatarURL: $0.avatarURL)
            })
        })
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Task { try? await markAllNotificationsReadUseCase.execute(userID: userID) }
    }
    
    func delete(id: String) {
        guard case .loaded(let groups) = state else { return }
        let updated = groups.map { NotificationDisplayGroup(id: $0.id, items: $0.items.filter { $0.id != id }) }
        state = updated.allSatisfy({ $0.items.isEmpty }) ? .empty : .loaded(updated)
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Task { try? await deleteNotificationUseCase.execute(notificationID: id, userID: userID) }
    }
    
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
    
#if DEBUG
    func insertTestNotification() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "userID": userID,
            "isRead": false,
            "type": "thread_reply",
            "createdAt": Timestamp(date: Date()),
            "actorName": "Jocelyn Duarte",
            "actorPhotoURL": "",
            "contextLabel": "Monthly Revenue"
        ]
        db.collection("users").document(userID)
            .collection("notifications").addDocument(data: data) { error in
                if let error {
                    print("❌ Error: \(error.localizedDescription)")
                } else {
                    print("✅ Notificación de prueba insertada")
                }
            }
    }

    func forceState(_ newState: NotificationsState) {
        state = newState
    }
    #endif
}
