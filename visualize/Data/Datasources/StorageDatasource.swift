//
//  StorageDatasource.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//
//
//  Thin Firebase Storage wrapper shared across features. The Snipping Tool uses
//  it to upload the exported edited image and obtain a download URL for the
//  Firestore comment payload.

/// Firebase Storage wrapper — the sole Firebase import for Storage operations.
import FirebaseStorage
import Foundation

final class StorageDatasource {

    // MARK: - Dependencies

    private let storage: Storage

    // MARK: - Init

    /// - Parameter storage: A Firebase Storage instance (defaults to `Storage.storage()`).
    init(storage: Storage = Storage.storage()) {
        self.storage = storage
    }

    // MARK: - Upload

    /// Uploads raw data to Firebase Storage at the given path and returns the download URL.
    /// - Parameters:
    ///   - data: The binary image data to upload.
    ///   - path: The storage path (e.g. `snips/userID/vizID_timestamp.png`).
    /// - Returns: The Firebase Storage download URL.
    func uploadImage(_ data: Data, path: String) async throws -> URL {
        let ref = storage.reference(withPath: path)
        _ = try await ref.putDataAsync(data)
        return try await ref.downloadURL()
    }
}
