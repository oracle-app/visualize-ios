//
//  DeleteProfilePhotoUseCase.swift
//  visualize
//
//  Created by Mariana Islas on 22/05/26.
//

import Foundation

/// Use case responsible for deleting the user's profile photo.
class DeleteProfilePhotoUseCase {
    
    // MARK: - Dependencies
    
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    
    // MARK: - Init
    
    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Execute
    
    /// Deletes the current user's profile photo from storage
    /// and clears the URL from their record in the database.
    ///
    /// - Throws: `AuthRepository` errors if the user is not logged in,
    ///   or `UserRepository` errors if the deletion fails.
    func execute() async throws {
        guard let user = authRepository.getCurrentUser() else {
            throw DeleteProfilePhotoError.noSession
        }

        // Get current profile to find the exact file URL
        let appUser = try await userRepository.getUserByID(userID: user.uid)
        
        // Delete file from Storage only if a URL exists
        if let urlString = appUser.profilePictureURL,
           let url = URL(string: urlString) {
            try? await userRepository.deleteProfileImage(byURL: url)
        }

        // Always clear the URL in Firestore
        try await userRepository.updateProfilePictureURL(
            userID: user.uid,
            url: nil
        )
    }
    
    enum DeleteProfilePhotoError: Error {
        case noSession
    }
}
