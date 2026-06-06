//
//  UploadProfilePhotoUseCase.swift
//  visualize
//
//  Created by Mariana Islas on 22/05/26.
//

import UIKit
import Foundation

/// Use case responsible for uploading the user's profile photo
/// taken from the camera or photo library.
class UploadProfilePhotoUseCase {

    // MARK: - Dependencies

    private let authRepository: AuthRepository
    private let userRepository: UserRepository

    // MARK: - Init

    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }

    // MARK: - Execute

    /// Uploads a new profile photo for the current user.
    ///
    /// - Parameter image: The UIImage captured from camera or gallery.
    /// - Returns: The updated photo URL (or whatever your backend returns).
    /// - Throws: `UploadProfilePhotoError.noSession` if user is not logged in.
    func execute(imageData: Data) async throws -> URL {
        guard let authUser = authRepository.getCurrentUser() else {
            throw UploadProfilePhotoError.noSession
        }

        // 1. Save the current URL before uploading so we can clean it up later
        let existingUser = try? await userRepository.getUserByID(userID: authUser.uid)
        let oldURL = existingUser?.profilePictureURL.flatMap { URL(string: $0) }

        // 2. Upload new photo to timestamped path
        let newURL = try await userRepository.uploadProfileImage(
            userID: authUser.uid,
            imageData: imageData
        )

        do {
            // 3. Save new URL to Firestore
            try await userRepository.updateProfilePictureURL(
                userID: authUser.uid,
                url: newURL
            )
        } catch {
            // Firestore failed — delete the new file, old one is still safe
            try? await userRepository.deleteProfileImage(byURL: newURL)
            throw error
        }

        // 4. Firestore succeeded — now safe to delete the old file
        if let oldURL {
            try? await userRepository.deleteProfileImage(byURL: oldURL)
        }

        return newURL
    }
    
    enum UploadProfilePhotoError: Error {
        case noSession
        case invalidImage
    }
}
