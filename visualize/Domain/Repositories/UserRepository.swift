//
//  UserRepository.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

protocol UserRepository {
    func getUserSuggestionsByEmail(email: String) async throws -> [AppUser]
}
