//
//  AuthUser.swift
//  visualize
//
//  Created by Libia Fv on 25/04/26.
//

// MARK: - Auth Model

/// Domain model that represents an authenticated user within the application.
///
/// This model is independent of any external frameworks or SDKs (such as Firebase),
/// ensuring that the domain layer remains clean and decoupled from infrastructure concerns.
struct AuthUser {
    // MARK: - Properties
    /// Unique identifier of the user.
    let uid: String
    /// Email address of the user.
    let email: String
}
