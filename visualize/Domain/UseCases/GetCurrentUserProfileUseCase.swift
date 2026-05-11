import Foundation

/// Use case responsible for retrieving the full profile of the currently authenticated user.
///
/// Combines `AuthRepository` to obtain the current session UID
/// and `UserRepository` to fetch the complete user profile from the database.
class GetCurrentUserProfileUseCase {

    // MARK: - Private properties

    private let authRepository: AuthRepository
    private let userRepository: UserRepository

    // MARK: - Initialization

    /// Initializes the use case with the required repositories.
    ///
    /// - Parameters:
    ///   - authRepository: The repository used to retrieve the current authenticated user.
    ///   - userRepository: The repository used to fetch the full user profile.
    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }

    // MARK: - Internal methods

    /// Retrieves the full profile of the currently authenticated user.
    ///
    /// - Returns: The domain user (`AppUser`) with the complete profile data.
    /// - Throws: `GetCurrentUserProfileError.noSession` if no user is logged in,
    ///           or a repository error if the fetch fails.
    func execute() async throws -> AppUser {
        guard let authUser: AuthUser = authRepository.getCurrentUser() else {
            throw GetCurrentUserProfileError.noSession
        }
        return try await userRepository.getUserByID(userID: authUser.uid)
    }
}

/// Errors specific to retrieving the current user profile.
enum GetCurrentUserProfileError: Error {
    case noSession
}
