//
//  NotificationDataSource.swift
//
//  created by Miguel Degollado on 26/05/2026

import Foundation
import FirebaseFirestore

final class NotificationDatasource {

    private let db: Firestore

    private final class ListenerBox: @unchecked Sendable {
        var registration: ListenerRegistration?
        func remove() { registration?.remove(); registration = nil }
    }

    init(db: Firestore = Firestore.firestore()) { self.db = db }

    // MARK: - Notifications stream

    func notificationsStream(for userID: String) -> AsyncStream<Result<[NotificationDTO], Error>> {
        let box = ListenerBox()
        return AsyncStream { continuation in
            let query = db
                .collection("notifications")
                .whereField("receiverID", isEqualTo: userID)
                .order(by: "createdAt", descending: true)

            box.registration = query.addSnapshotListener { snapshot, error in
                if let error {
                    continuation.yield(.failure(error))
                    return
                }
                let dtos: [NotificationDTO] = snapshot?.documents.compactMap {
                    try? $0.data(as: NotificationDTO.self)
                } ?? []
                continuation.yield(.success(dtos))
            }
            continuation.onTermination = { _ in box.remove() }
        }
    }

    // MARK: - Unread stream

    func unreadStream(for userID: String) -> AsyncStream<Bool> {
        let box = ListenerBox()
        return AsyncStream { continuation in
            box.registration = db
                .collection("notifications")
                .whereField("receiverID", isEqualTo: userID)
                .whereField("isRead", isEqualTo: false)
                .addSnapshotListener { snapshot, _ in
                    continuation.yield((snapshot?.documents.count ?? 0) > 0)
                }
            continuation.onTermination = { _ in box.remove() }
        }
    }

    // MARK: - Mark as read

    func markAsRead(notificationID: String) async throws {
        try await db
            .collection("notifications")
            .document(notificationID)
            .updateData(["isRead": true])
    }

    func markAllAsRead(userID: String) async throws {
        let snapshot = try await db
            .collection("notifications")
            .whereField("receiverID", isEqualTo: userID)
            .whereField("isRead", isEqualTo: false)
            .getDocuments()
        guard !snapshot.documents.isEmpty else { return }
        let batch = db.batch()
        snapshot.documents.forEach {
            batch.updateData(["isRead": true], forDocument: $0.reference)
        }
        try await batch.commit()
    }
}
