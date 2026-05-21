//
//  UploadSnipUseCase.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//

import UIKit

/// Converts a snip image to PNG, builds a namespaced Storage path, and uploads.
struct UploadSnipUseCase {

    // MARK: - Dependencies

    private let snipRepository: any SnipRepository

    // MARK: - Init

    /// - Parameter snipRepository: Repository responsible for uploading snip images.
    init(snipRepository: any SnipRepository) {
        self.snipRepository = snipRepository
    }

    // MARK: - Execute

    /// Encodes the image as PNG and uploads it to a user-namespaced Storage path.
    /// - Parameters:
    ///   - image: The annotated snip image to upload.
    ///   - userID: The ID of the user uploading the snip.
    ///   - visualizationID: The ID of the visualization the snip belongs to.
    /// - Returns: The Firebase Storage download URL for Kim's Firestore payload.
    func execute(image: UIImage, userID: String, visualizationID: String) async throws -> URL {
        guard let data = image.pngData() else {
            throw SnipUploadError.imageConversionFailed
        }
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let path = "snips/\(userID)/\(visualizationID)_\(timestamp).png"
        return try await snipRepository.uploadSnip(data: data, path: path)
    }
}

// MARK: - SnipUploadError

enum SnipUploadError: LocalizedError {
    case imageConversionFailed

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Could not convert the snip image for upload."
        }
    }
}
