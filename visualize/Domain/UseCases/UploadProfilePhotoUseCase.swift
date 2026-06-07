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
    /// - Parameter imageData: The compressed image data to upload.
    /// - Returns: The download URL of the newly uploaded photo.
    /// - Throws: `UploadProfilePhotoError.noSession` if no user is logged in.
    func execute(imageData: Data) async throws -> URL {
        guard let authUser = authRepository.getCurrentUser() else {
            throw UploadProfilePhotoError.noSession
        }

        let existingUser = try? await userRepository.getUserByID(userID: authUser.uid)
        let oldURL = existingUser?.profilePictureURL.flatMap { URL(string: $0) }

        let newURL = try await userRepository.uploadProfileImage(
            userID: authUser.uid,
            imageData: imageData
        )

        do {
            try await userRepository.updateProfilePictureURL(
                userID: authUser.uid,
                url: newURL
            )
        } catch {
            try? await userRepository.deleteProfileImage(byURL: newURL)
            throw error
        }

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
