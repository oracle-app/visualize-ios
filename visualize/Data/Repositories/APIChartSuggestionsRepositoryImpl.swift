//
//  APIChartSuggestionsRepositoryImpl.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 20/05/26.
//

/// Live implementation of `ChartSuggestionsRepository` backed by the analyze microservice.
///
/// For each chart index (0–4), makes two independent requests:
/// 1. `GET /results/{taskId}?chart=N&preview=true`, 100-point payload stored as `previewJSON`,
///    used to render cards in VizReady and the feed.
/// 2. `GET /results/{taskId}?chart=N&page=0` , 5 000-point payload stored as `configJSON`, persisted in Firestore and loaded by FullScreenView for full-detail rendering.
///
/// If either request for a chart fails, that chart is skipped and loading continues for the rest.
/// Results are returned sorted ascending by `chartIndex`.

import Foundation

struct APIChartSuggestionsRepositoryImpl: ChartSuggestionsRepository {

    // MARK: - Dependencies

    private let service: AnalyzeAPIService

    // MARK: - Init

    /// - Parameter service: HTTP service pointing at the microservice base URL.
    init(service: AnalyzeAPIService = AnalyzeAPIService(baseURL: AppConfig.analyzeMicroserviceURL)) {
        self.service = service
    }

    // MARK: - ChartSuggestionsRepository

    func getSuggestions(taskId: String) async throws -> [ChartSuggestion] {
            var suggestions: [ChartSuggestion] = []
     
            for chartIndex in 0...4 {
                do {
                    // Preview request (100 pts) -> rendered in VizReady cards and feed.
                    let previewDTO = try await service.fetchPreview(taskId: taskId, chart: chartIndex)
                    // Full-data request (5 000 pts) -> stored as configJSON for FullScreen.
                    let configDTO  = try await service.fetchChartPage(taskId: taskId, chart: chartIndex, page: 0)
     
                    guard
                        let previewJSON = previewDTO.toJSONString(),
                        let configJSON  = configDTO.toJSONString()
                    else { continue }
     
                    if let suggestion = ChartConfigParser.parseSuggestion(configJSON: configJSON, previewJSON: previewJSON) {
                        suggestions.append(suggestion)
                    }
                } catch {
                    print("APIChartSuggestionsRepositoryImpl: failed to fetch chart \(chartIndex) — \(error)")
                }
            }
     
            return suggestions.sorted { $0.id < $1.id }
        }
    }
