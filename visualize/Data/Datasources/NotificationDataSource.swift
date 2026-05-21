//
//  NotificationDataSource.swift
//  visualize
//
//  Created by Miguel Degollado on 20/05/26.

import Foundation
import FirebaseFirestore

final class NotificationDatasource {

    private let db: Firestore

    private final class ListenerBox: @unchecked Sendable {
        var registration: ListenerRegistration?
        func remove() { registration?.remove(); registration = nil }
    }

    init(db: Firestore = Firestore.firestore()) { self.db = db }

    func notificationsStream(for userID: String) -> AsyncStream<[NotificationDTO]> {
        let box = ListenerBox()
        return AsyncStream { continuation in
            let query = db.collection("users").document(userID)
                .collection("notifications").order(by: "createdAt", descending: true)
            box.registration = query.addSnapshotListener { snapshot, error in
                if let error {
                    print("[NotificationDatasource] error: \(error.localizedDescription)")
                    continuation.yield([])
                    return
                }
                let dtos: [NotificationDTO] = snapshot?.documents.compactMap {
                    try? $0.data(as: NotificationDTO.self)
                } ?? []
                continuation.yield(dtos)
            }
            continuation.onTermination = { _ in box.remove() }
        }
    }

    func markAsRead(notificationID: String, userID: String) async throws {
        try await db.collection("users").document(userID)
            .collection("notifications").document(notificationID)
            .updateData(["isRead": true])
    }

    func markAllAsRead(userID: String) async throws {
        let snapshot = try await db.collection("users").document(userID)
            .collection("notifications").whereField("isRead", isEqualTo: false).getDocuments()
        guard !snapshot.documents.isEmpty else { return }
        let batch = db.batch()
        snapshot.documents.forEach { batch.updateData(["isRead": true], forDocument: $0.reference) }
        try await batch.commit()
    }

    func delete(notificationID: String, userID: String) async throws {
        try await db.collection("users").document(userID)
            .collection("notifications").document(notificationID).delete()
    }

    func saveFCMToken(_ token: String, for userID: String) async throws {
        try await db.collection("users").document(userID).updateData(["fcmToken": token])
    }

    func removeFCMToken(for userID: String) async throws {
        try await db.collection("users").document(userID)
            .updateData(["fcmToken": FieldValue.delete()])
    }
}
