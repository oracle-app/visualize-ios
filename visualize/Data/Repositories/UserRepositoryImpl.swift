//
//  UserRepositoryImpl.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

class UserRepositoryImpl: UserRepository {

    private let userDatasource: UserDatasource
    init(userDatasource: UserDatasource) {
        self.userDatasource = userDatasource
    }
    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser] {
        let usersRaw: [UserDTO] = try await userDatasource.getUserSuggestionsByEmail(email: email)
        return usersRaw.map { $0.toAppUser() }
    }
    
    /// Creates a new user in the remote data source and returns the created user
    /// mapped into the domain model.
    ///
    /// This method:
    /// - Transforms the domain `AppUser` into a `UserDTO`
    /// - Sends it to the `UserDatasource` for persistence
    /// - Receives the stored user data
    /// - Maps it back into the domain model (`AppUser`)
    ///
    /// - Parameter user: The domain user to be created.
    /// - Returns: The created user as a domain `AppUser`.
    /// - Throws: An error if the user creation process fails.
    func createUser(user: AppUser) async throws -> AppUser {
        let uid = user.id
        let dto = UserDTO(
            id: uid,
            chartTheme: "",
            email: user.email,
            profilePictureURL: user.profilePictureURL ?? "",
            themePreference: "",
            userType: "ADMIN",
            username: user.username,
            hiddenVisualizations: [""]
        )
        let userRaw: UserDTO = try await userDatasource.createUser(
            user: dto,
            uid: user.id
        )
        return userRaw.toAppUser()
    }
}
