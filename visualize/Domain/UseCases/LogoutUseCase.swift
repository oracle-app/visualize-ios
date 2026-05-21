import Foundation

/// Use case responsible for handling the logout business logic.
///
/// Delegates the sign-out operation to `AuthRepository`.
class LogoutUseCase {

    // MARK: - Private properties

    private let repository: AuthRepository

    // MARK: - Initialization

    /// Initializes the use case with an authentication repository.
    ///
    /// - Parameter repository: The repository responsible for authentication operations.
    init(repository: AuthRepository) {
        self.repository = repository
    }

    // MARK: - Internal methods

    /// Executes the logout process by signing out the current user.
    ///
    /// - Throws: An error if the sign-out process fails.
    func execute() throws {
        try repository.logout()
    }
}
