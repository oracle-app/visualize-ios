//
//  AuthUserMapper.swift
//  visualize
//
//  Created by Libia Fv on 25/04/26.
//

import FirebaseAuth

// MARK: - FirebaseAuth User Mapping

extension FirebaseAuth.User {
    
    /// Converts a FirebaseAuth.User model into a domain-level AuthUser model.
    ///
    /// This mapping isolates the Firebase SDK dependency from the domain layer,
    /// ensuring that the rest of the app does not directly rely on Firebase types.
    ///
    /// - Returns: A domain `AuthUser` containing only the necessary user information.
    func toDomain() -> AuthUser {
        return AuthUser(
            uid: self.uid,
            email: self.email ?? ""
        )
    }
}
