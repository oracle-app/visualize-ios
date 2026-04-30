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
    
}
