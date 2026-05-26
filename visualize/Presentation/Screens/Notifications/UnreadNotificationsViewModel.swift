//
//  UnreadNotificationsViewModel.swift
//  visualize
//
//  Fix PR #2: removed FirebaseAuth and FirebaseFirestore imports.
//  Unread listener logic moved behind ObserveUnreadNotificationsUseCase.
//

import Foundation
import Combine

@MainActor
final class UnreadNotificationsViewModel: ObservableObject {

    @Published private(set) var hasUnread: Bool = false

    private let authRepository: AuthRepository
    private let observeUnreadUseCase: ObserveUnreadNotificationsUseCase
    private var listenerTask: Task<Void, Never>?
    private var notificationObservers: [NSObjectProtocol] = []
    private var isPaused: Bool = false

    init(authRepository: AuthRepository, observeUnreadUseCase: ObserveUnreadNotificationsUseCase) {
        self.authRepository = authRepository
        self.observeUnreadUseCase = observeUnreadUseCase
        setupScreenObservers()
        startListening()
    }

    deinit {
        listenerTask?.cancel()
        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Listener lifecycle

    private func startListening() {
        guard !isPaused,
              let userID = authRepository.getCurrentUser()?.uid else { return }
        listenerTask?.cancel()
        listenerTask = Task {
            for await hasUnread in observeUnreadUseCase.execute(for: userID) {
                guard !Task.isCancelled else { break }
                self.hasUnread = hasUnread
            }
        }
    }

    private func pause() {
        isPaused = true
        listenerTask?.cancel()
        listenerTask = nil
    }

    private func resume() {
        isPaused = false
        startListening()
    }

    // MARK: - Screen coordination

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
