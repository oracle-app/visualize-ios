import Observation

/// Manages the authentication session state across the application.
///
/// This observable class is used by `ContentView` to determine
/// whether to display the login screen or the main app navigation.
@MainActor
@Observable
final class SessionManager {

    // MARK: - Internal properties

    private(set) var isLoggedIn: Bool

    // MARK: - Initialization

    /// Initializes the session manager with the current authentication state.
    ///
    /// - Parameter isLoggedIn: Whether a user session currently exists.
    init(isLoggedIn: Bool) {
        self.isLoggedIn = isLoggedIn
    }

    // MARK: - Internal methods

    /// Updates the session state to reflect a successful login.
    func didLogIn() {
        isLoggedIn = true
    }

    /// Updates the session state to reflect a successful logout.
    func didLogOut() {
        isLoggedIn = false
    }
}
