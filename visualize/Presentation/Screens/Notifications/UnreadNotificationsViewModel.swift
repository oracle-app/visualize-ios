//
//  UnreadNotificationsViewModel.swift
//  visualize
//
//  Created by SOPORTE on 20/05/26.
//

//
//  UnreadNotificationsViewModel.swift
//  visualize
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class UnreadNotificationsViewModel: ObservableObject {

    @Published private(set) var hasUnread: Bool = false

    private var listenerRegistration: ListenerRegistration?
    private var notificationObservers: [NSObjectProtocol] = []
    private var isPaused: Bool = false

    init() {
        setupScreenObservers()
        startListening()
    }

    deinit {
        listenerRegistration?.remove()
        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    private func startListening() {
        guard !isPaused, let userID = Auth.auth().currentUser?.uid else { return }
        listenerRegistration?.remove()
        listenerRegistration = Firestore.firestore()
            .collection("users").document(userID)
            .collection("notifications")
            .whereField("isRead", isEqualTo: false)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self else { return }
                let count = snapshot?.documents.count ?? 0
                Task { @MainActor [weak self] in self?.hasUnread = count > 0 }
            }
    }

    private func pause() {
        isPaused = true
        listenerRegistration?.remove()
        listenerRegistration = nil
    }

    private func resume() {
        isPaused = false
        startListening()
    }

    private func setupScreenObservers() {
        notificationObservers = [
            NotificationCenter.default.addObserver(
                forName: .notificationsScreenDidAppear, object: nil, queue: .main
            ) { [weak self] _ in Task { @MainActor [weak self] in self?.pause() } },

            NotificationCenter.default.addObserver(
                forName: .notificationsScreenDidDisappear, object: nil, queue: .main
            ) { [weak self] _ in Task { @MainActor [weak self] in self?.resume() } }
        ]
    }

    func stopListening() {
        pause()
        hasUnread = false
    }
}
