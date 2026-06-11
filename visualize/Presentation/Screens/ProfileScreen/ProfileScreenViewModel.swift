//
//  ProfileScreenViewModel.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 28/04/26.
//

import Foundation
import Observation
import UIKit

/// Manages the state and user actions for the profile screen.
@MainActor
@Observable
final class ProfileScreenViewModel {
    // MARK: - Internal properties
    
    private(set) var username: String = ""
    private(set) var email: String = ""
    private(set) var profilePictureURL: URL?
    private(set) var isLoadingProfile: Bool = false
    private(set) var profileError: String?
    private(set) var isUploadingPhoto: Bool = false
    private(set) var logoutError: String?

    var aboutItems: [AboutItem] {
        [
            .info(String(localized: "Version 1.0.0")),
            .info(String(localized: "Developed by VisTeam.")),
            .action(String(localized: "Terms of Service")) { [weak self] in
                self?.openTermsOfService()
            },
            .action(String(localized: "Licenses and open source libraries")) { [weak self] in
                self?.openLicenses()
            }
        ]
    }
    
    private(set) var isLoggedOut: Bool = false
    
    // MARK: - Private properties
    
    private let logoutUseCase: LogoutUseCase
    private let getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase
    private let uploadProfilePhotoUseCase: UploadProfilePhotoUseCase
    private let deleteProfilePhotoUseCase: DeleteProfilePhotoUseCase
    
    // MARK: - Initialization
    
    init(
        logoutUseCase: LogoutUseCase,
        getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase,
        uploadProfilePhotoUseCase: UploadProfilePhotoUseCase,
        deleteProfilePhotoUseCase: DeleteProfilePhotoUseCase
    ) {
        self.logoutUseCase = logoutUseCase
        self.getCurrentUserProfileUseCase = getCurrentUserProfileUseCase
        self.uploadProfilePhotoUseCase = uploadProfilePhotoUseCase
        self.deleteProfilePhotoUseCase = deleteProfilePhotoUseCase
    }
    
    // MARK: - Internal methods
    
    /// Loads the current user profile from the database.
    func loadProfile() {
        Task {
            isLoadingProfile = true
            do {
                let user: AppUser = try await getCurrentUserProfileUseCase.execute()
                username = user.username
                email = user.email
                if let urlString = user.profilePictureURL {
                    profilePictureURL = URL(string: urlString)
                }
            } catch {
                profileError = error.localizedDescription
            }
            isLoadingProfile = false
        }
    }
    
    /// Uploads a new profile image for the current user.
    func uploadProfileImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            profileError = String(localized: "Could not process image")
            return
        }
        isUploadingPhoto = true
        Task {
            do {
                let url = try await uploadProfilePhotoUseCase.execute(imageData: imageData)
                profilePictureURL = url
            } catch {
                profileError = error.localizedDescription
            }
            isUploadingPhoto = false
        }
    }
    
    /// Deletes the current user's profile image.
    func deleteProfileImage() {
        Task {
            do {
                try await deleteProfilePhotoUseCase.execute()
                
                profilePictureURL = nil
                
            } catch {
                profileError = error.localizedDescription
            }
        }
    }
    
    /// Handles the logout action.
    func logOut() {
        do {
            try logoutUseCase.execute()
            isLoggedOut = true
        } catch {
            logoutError = error.localizedDescription
        }
    }
    
    // MARK: - Private methods
    
    private func openTermsOfService() {
        // TODO: Implement in feature/profile/terms-of-service
    }
    
    private func openLicenses() {
        // TODO: Implement in feature/profile/licenses
    }
}
