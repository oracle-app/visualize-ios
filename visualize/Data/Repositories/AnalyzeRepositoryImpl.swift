//
//  AnalyzeRepositoryImpl.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 20/05/26.
//

/// Default implementation of `AnalyzeRepository` backed by `AnalyzeAPIService`.
/// Delegates the multipart upload and delegates error handling to the service layer.

import Foundation

struct AnalyzeRepositoryImpl: AnalyzeRepository {

    // MARK: - Dependencies

    private let service: AnalyzeAPIService

    // MARK: - Init

    /// - Parameter service: HTTP service to use. Defaults to the configured microservice URL.
    init(service: AnalyzeAPIService = AnalyzeAPIService(baseURL: AppConfig.analyzeMicroserviceURL)) {
        self.service = service
    }

    // MARK: - AnalyzeRepository

    func uploadDataset(fileURL: URL) async throws -> String {
        try await service.uploadDataset(fileURL: fileURL)
    }
}
