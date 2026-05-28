//
//  AppConfig.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 24/05/26.
//

import Foundation

enum AppConfig {
    /// Base URL of the analyze microservice.
    /// Used by `AnalyzeAPIService` and injected into `AnalyzeRepositoryImpl`.
    /// - Note: This is currently hardcoded for local simulator development.
    ///   Replace with a staging or production URL via `.xcconfig` before deploying to physical devices or production.
    static let analyzeMicroserviceURL: URL = URL(string: "http://localhost:8080")!
}
