//
//  SnipRepositoryImpl.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//

import Foundation

/// Concrete snip repository that delegates image upload operations to Firebase Storage.
final class SnipRepositoryImpl: SnipRepository {

    // MARK: - Dependencies

    private let storageDatasource: StorageDatasource

    // MARK: - Init

    /// - Parameter storageDatasource: The Firebase Storage datasource.
    init(storageDatasource: StorageDatasource) {
        self.storageDatasource = storageDatasource
    }

    // MARK: - SnipRepository

    func uploadSnip(data: Data, path: String) async throws -> URL {
        try await storageDatasource.uploadImage(data, path: path)
    }
}
