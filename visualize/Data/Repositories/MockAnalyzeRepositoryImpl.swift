//
//  MockAnalyzeRepositoryImpl.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 08/06/26.
//

import Foundation

/// Mock implementation of `AnalyzeRepository` used for demo and local testing.
///
/// It avoids calling the live analyze microservice and returns a stable mock task id.
/// The task id is only used to satisfy the Generate Visualization flow before
/// `MockChartSuggestionsRepositoryImpl` returns bundled chart suggestions.
struct MockAnalyzeRepositoryImpl: AnalyzeRepository {

    // MARK: - AnalyzeRepository

    func uploadDataset(fileURL: URL) async throws -> String {
        "mock-task-id"
    }
}
