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

        let url = try await userRepository.uploadProfileImage(
            userID: authUser.uid,
            imageData: imageData
        )

        do {
            try await userRepository.updateProfilePictureURL(
                userID: authUser.uid,
                url: url
            )
        } catch {
            try? await userRepository.deleteProfileImage(userID: authUser.uid)
            throw error
        }

        return url
    }
    
    enum UploadProfilePhotoError: Error {
        case noSession
        case invalidImage
    }
}
