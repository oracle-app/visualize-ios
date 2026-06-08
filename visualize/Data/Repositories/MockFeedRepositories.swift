//
//  FeedMocks.swift
//  visualize
//
//  Created by Jorge Flores on 07/06/26.
//

//
//  FeedMocks.swift
//  Visualize
//

#if DEBUG
import Foundation

// MARK: - MockVisualizationRepository (privado, solo para inicializar mocks)

private final class MockVisualizationRepository: VisualizationRepository {
    func updateSharing(visualizationID: String, userIDs: [String], teamIDs: [String]) async throws {}
    func getAllVisualizations(userID: String) async throws -> [VisualizationCard] { [] }
    func searchVisualizations(userID: String, query: String) async throws -> [VisualizationCard] { [] }
    func deleteVisualization(visualizationID: String) async throws {}
    func removeUserFromSharedWith(visualizationID: String, userID: String) async throws {}
    func createVisualization(title: String, authorID: String, configJSON: String, previewJSON: String, userIDs: [String], teamIDs: [String]) async throws {}
    func fetchConfigJSON(visualizationID: String) async throws -> String? { nil }
}

// MARK: - MockLoadVisualizationsUseCase

final class MockLoadVisualizationsUseCase: LoadVisualizationsUseCaseProtocol {
    var stubbedItems: [VisualizationCard] = []
    var shouldThrow: Bool = false
    var shouldBlockForever: Bool = false  // ← reemplaza stubbedDelay
    private(set) var executeCallCount: Int = 0

    func execute(userID: String) async throws -> [VisualizationCard] {
        executeCallCount += 1
        if shouldBlockForever {
            try await Task.sleep(for: .seconds(9_999))
        }
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return stubbedItems
    }
}

// MARK: - MockSearchVisualizationsUseCase

final class MockSearchVisualizationsUseCase: SearchVisualizationsUseCase {
    var stubbedResults: [VisualizationCard] = []
    var shouldThrow: Bool = false

    init() {
        super.init(visualizationRepository: MockVisualizationRepository())
    }

    override func execute(userID: String, query: String) async throws -> [VisualizationCard] {
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return stubbedResults
    }
}

// MARK: - MockHideVisualizationUseCase

final class MockHideVisualizationUseCase: HideVisualizationUseCaseProtocol {
    var shouldThrow: Bool = false
    private(set) var hiddenVisualizationID: String?

    func execute(userID: String, visualizationID: String) async throws {
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        hiddenVisualizationID = visualizationID
    }
}

// MARK: - MockDeleteVisualizationUseCase

final class MockDeleteVisualizationUseCase: DeleteVisualizationUseCaseProtocol {
    var shouldThrow: Bool = false
    private(set) var deletedVisualizationID: String?

    func execute(visualizationID: String) async throws {
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        deletedVisualizationID = visualizationID
    }
}

// MARK: - FeedMockAuthRepository

final class FeedMockAuthRepository: AuthRepository {
    var userID: String = "user-123"
    var shouldThrow: Bool = false

    func getCurrentUserID() async throws -> String {
        if shouldThrow { throw URLError(.userAuthenticationRequired) }
        return userID
    }

    func login(email: String, password: String) async throws -> AuthUser {
        AuthUser(uid: userID, email: email)
    }

    func register(email: String, password: String) async throws -> AuthUser {
        AuthUser(uid: userID, email: email)
    }

    func logout() throws {}
    func getCurrentUser() -> AuthUser? { nil }
    func deleteCurrentUser() async throws {}
    func sendPasswordReset(to email: String) async throws {}
}

// MARK: - MockNotificationRepository

final class MockNotificationRepository: NotificationRepository {
    var hasUnread: Bool = false

    func notificationsStream(for userID: String) -> AsyncStream<Result<[Notification], Error>> {
        AsyncStream { continuation in
            continuation.yield(.success([]))
            continuation.finish()
        }
    }

    func unreadStream(for userID: String) -> AsyncStream<Bool> {
        let value = hasUnread
        return AsyncStream { continuation in
            continuation.yield(value)
            continuation.finish()
        }
    }

    func markAsRead(notificationID: String) async throws {}
    func markAllAsRead(userID: String) async throws {}
}

// MARK: - MockUserRepository

final class MockUserRepository: UserRepository {
    var role: Role = .consumer
    var shouldThrow: Bool = false

    func getUserByID(userID: String) async throws -> AppUser {
        if shouldThrow { throw URLError(.resourceUnavailable) }
        return AppUser(
            id: userID,
            email: "test@test.com",
            profilePictureURL: nil,
            username: "Test User",
            role: role
        )
    }

    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] { [] }
    func createUser(user: AppUser) async throws -> AppUser { user }
    func addHiddenVisualization(userID: String, visualizationID: String) async throws {}
    func removeHiddenVisualization(userID: String, visualizationID: String) async throws {}
    func updateProfilePictureURL(userID: String, url: URL?) async throws {}
    func uploadProfileImage(userID: String, imageData: Data) async throws -> URL { URL(string: "https://test.com")! }
    func deleteProfileImage(byURL url: URL) async throws {}
}

// MARK: - VisualizationCard test helper

extension VisualizationCard {
    static func make(
        id: String = UUID().uuidString,
        title: String = "Test Card",
        authorID: String = "user-123"
    ) -> VisualizationCard {
        VisualizationCard(
            id: id,
            title: title,
            author: "Test Author",
            authorID: authorID,
            createdAt: Date(),
            previewJSON: "",
            teamsSharedWith: [],
            usersSharedWith: [],
            allUsersSharedWith: [],
        )
    }
}
#endif
