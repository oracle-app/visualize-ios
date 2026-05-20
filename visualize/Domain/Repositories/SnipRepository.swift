//
//  SnipRepository.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//

/// Contract for snip upload operations.
import Foundation

protocol SnipRepository {
    /// Uploads a snip image to remote storage.
    /// - Parameters:
    ///   - data: The PNG image data to upload.
    ///   - path: The storage path where the image should be stored.
    /// - Returns: The download URL of the uploaded image.
    func uploadSnip(data: Data, path: String) async throws -> URL
}
