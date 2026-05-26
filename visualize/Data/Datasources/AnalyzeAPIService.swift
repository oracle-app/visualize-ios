//
//  AnalyzeAPIService.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 20/05/26.
//

/// HTTP datasource for the analyze microservice.
///
/// Three endpoints:
/// - `POST /analyzeData` , multipart upload of the dataset file.
/// - `GET  /results/{taskId}` , overview of all generated charts (preview payloads).
/// - `GET  /results/{taskId}?chart=N&page=N` , single chart at full detail.
///
/// The base URL is injected at init time so the same service can point to
/// Simulator, a staging host, or production without recompiling. See `AppConfig.analyzeMicroserviceURL`.
///
/// All methods are `async throws`. Network errors propagate as `URLError`;
/// HTTP 4xx/5xx responses throw `URLError(.badServerResponse)` after the `validate(response:)` guard.

import Foundation
 
struct AnalyzeAPIService {
 
    // MARK: - Properties
 
    /// Root URL of the microservice. All endpoint paths are appended to this.
    let baseURL: URL
 
    /// URLSession used for requests. Defaulting to `.shared`; tests can inject a stub session.
    private let session: URLSession
 
    // MARK: - Init
 
    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
 
    // MARK: - Endpoints
 
    /// Uploads the dataset file as `multipart/form-data` to `POST /analyzeData`.
    ///
    /// The multipart body contains a single part named `"file"` with the file's
    /// bytes, filename, and MIME type (text/csv or the xlsx variant).
    ///
    /// - Parameter fileURL: Local URL of the dataset. The file must exist and be readable.
    /// - Returns: The `taskId` returned by the server, used in subsequent results requests.
    /// - Throws: File read errors, `URLError` on network/HTTP failure.
    func uploadDataset(fileURL: URL) async throws -> String {
        let endpoint = baseURL.appendingPathComponent("analyzeData")
        let boundary = "Boundary-\(UUID().uuidString)"
 
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
 
        let body = try multipartBody(fileURL: fileURL, boundary: boundary)
        let (data, response) = try await session.upload(for: request, from: body)
        try validate(response: response)
 
        return try JSONDecoder().decode(AnalyzeTaskResponseDTO.self, from: data).taskId
    }
 
    /// Fetches a single chart at preview size via `GET /results/{taskId}?chart=N&preview=true`.
    ///
    /// Returns up to 100 data points, suitable for VizReady card rendering and feed display.
    ///
    /// - Parameters:
    ///   - taskId: The task identifier from upload.
    ///   - chart: Zero-based chart index.
    /// - Returns: A `ChartResponseDTO` with preview-sized data payload.
    /// - Throws: `URLError` on network/HTTP failure.
    func fetchPreview(taskId: String, chart: Int) async throws -> ChartResponseDTO {
        var components = URLComponents(
            url: baseURL
                .appendingPathComponent("results")
                .appendingPathComponent(taskId),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "chart",   value: String(chart)),
            URLQueryItem(name: "preview", value: "true")
        ]
        guard let url = components.url else { throw URLError(.badURL) }
 
        let (data, response) = try await session.data(from: url)
        try validate(response: response)
 
        return try JSONDecoder().decode(ChartResponseDTO.self, from: data)
    }
 
    /// Fetches a single chart at full detail via `GET /results/{taskId}?chart=N&page=N`.
    ///
    /// Returns up to 5 000 data points per page, intended for FullScreen rendering.
    ///
    /// - Parameters:
    ///   - taskId: The task identifier from upload.
    ///   - chart: Zero-based chart index.
    ///   - page: Page index within the chart's paged results (zero-based).
    /// - Returns: A `ChartResponseDTO` with the full data payload for the requested page.
    /// - Throws: `URLError` on network/HTTP failure.
    func fetchChartPage(taskId: String, chart: Int, page: Int) async throws -> ChartResponseDTO {
        var components = URLComponents(
            url: baseURL
                .appendingPathComponent("results")
                .appendingPathComponent(taskId),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "chart", value: String(chart)),
            URLQueryItem(name: "page",  value: String(page))
        ]
        guard let url = components.url else { throw URLError(.badURL) }
 
        let (data, response) = try await session.data(from: url)
        try validate(response: response)
 
        return try JSONDecoder().decode(ChartResponseDTO.self, from: data)
    }
 
    // MARK: - Private Helpers
 
    /// Builds the multipart/form-data body for the dataset upload.
    private func multipartBody(fileURL: URL, boundary: String) throws -> Data {
        let fileData  = try Data(contentsOf: fileURL)
        let filename  = fileURL.lastPathComponent
        let mime      = mimeType(for: fileURL)
 
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mime)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
 
    /// Returns the appropriate MIME type for the given file extension.
    private func mimeType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "csv":  return "text/csv"
        case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "xls":  return "application/vnd.ms-excel"
        default:     return "application/octet-stream"
        }
    }
 
    /// Throws `URLError(.badServerResponse)` if the response is not 2xx.
    private func validate(response: URLResponse) throws {
        guard
            let http = response as? HTTPURLResponse,
            (200...299).contains(http.statusCode)
        else { throw URLError(.badServerResponse) }
    }
}
