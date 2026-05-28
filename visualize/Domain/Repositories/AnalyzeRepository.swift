//
//  AnalyzeRepository.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 20/05/26.
//

/// Domain-layer contract for uploading a dataset to the analyze microservice.
///
/// Implementations:
/// - `AnalyzeRepositoryImpl`, delegates to `AnalyzeAPIService`.
///
/// The returned `taskId` is passed to `ChartSuggestionsRepository.getSuggestions(taskId:)`
/// to fetch the generated chart suggestions once processing is complete.

import Foundation

protocol AnalyzeRepository {
    /// Uploads the dataset at `fileURL` to the analyze service.
    /// - Parameter fileURL: Stable local URL of the file. Must remain readable for the duration of the upload.
    /// - Returns: The `taskId` assigned by the server.
    /// - Throws: Any networking or server error.
    func uploadDataset(fileURL: URL) async throws -> String
}
