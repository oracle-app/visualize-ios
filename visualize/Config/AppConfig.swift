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
    static let analyzeMicroserviceURL: URL = URL(string: "http://localhost:8080")!
}
