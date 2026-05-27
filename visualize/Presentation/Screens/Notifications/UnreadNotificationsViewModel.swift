//
//  UnreadNotificationsViewModel.swift
//  visualize
//
//  Fix PR #2: removed FirebaseAuth and FirebaseFirestore imports.
//  Unread listener logic moved behind ObserveUnreadNotificationsUseCase.
//

import Foundation

@MainActor
@Observable
final class UnreadNotificationsViewModel {

    private(set) var hasUnread: Bool = false

    private let authRepository: AuthRepository
    private let notificationRepository: any NotificationRepository
    
    private var isPaused: Bool = false
    private(set) var currentUserID: String = ""
    private let cleanupBox = UnreadCleanupBox()

    init(
        authRepository: AuthRepository,
        notificationRepository: NotificationRepository
    ) {
        self.authRepository = authRepository
        self.notificationRepository = notificationRepository
        setupScreenObservers()
        Task {
            await initializeUser()
        }
    }
    
    private func initializeUser() async {
        do {
            self.currentUserID = try await authRepository.getCurrentUserID()
            self.startListening()
        } catch {
            print("Error fetching user ID for unread notifications: \(error)")
        }
    }

    // MARK: - Listener lifecycle

    private func startListening() {
        guard !isPaused, !currentUserID.isEmpty else { return }
        
        cleanupBox.task?.cancel()
        cleanupBox.task = Task {
            for await unread in notificationRepository.unreadStream(for: currentUserID) {
                guard !Task.isCancelled else { break }
                self.hasUnread = unread
            }
        }
    }

    private func pause() {
        isPaused = true
        cleanupBox.task?.cancel()
        cleanupBox.task = nil
    }

    private func resume() {
        isPaused = false
        startListening()
    }

    // MARK: - Screen coordination

    private func setupScreenObservers() {
        cleanupBox.observers = [
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

private final class UnreadCleanupBox: @unchecked Sendable {
    var task: Task<Void, Never>?
    var observers: [NSObjectProtocol] = []
    
    deinit {
        task?.cancel()
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }
}
