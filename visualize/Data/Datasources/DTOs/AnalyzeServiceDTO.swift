//
//  AnalyzeServiceDTO.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 20/05/26.
//

/// `Decodable` DTOs for the two response shapes returned by the analyze microservice.
///
/// # Endpoint map
/// ```
/// POST /analyzeData -> AnalyzeTaskResponseDTO (contains task_id)
/// GET  /results/{taskId}?chart=N&preview=true -> ChartResponseDTO (single chart, preview)
/// GET  /results/{taskId}?chart=N&page=N -> ChartResponseDTO (single chart, full detail)
/// ```
 
import Foundation
 
// MARK: - AnalyzeTaskResponseDTO
 
/// Response of `POST /analyzeData`.
/// The `task_id` field uses a snake_case key in the wire format;
/// `CodingKeys` maps it to the Swift-idiomatic `taskId`.
struct AnalyzeTaskResponseDTO: Decodable {
    let message: String?
    let status: String?
    /// Identifier used in all subsequent `/results/{taskId}` requests.
    let taskId: String
 
    enum CodingKeys: String, CodingKey {
        case message, status
        case taskId = "task_id"
    }
}
 
// MARK: - ChartResponseDTO
 
/// A single chart entry returned by the microservice.
///
/// `data` and `metrics` are captured as `AnyJSON` rather than typed structs because:
/// - Their internal shape varies significantly per chart type.
/// - `ChartConfigParser` already knows how to decode them, we just need to preserve
///   the raw bytes and hand them back as a JSON string.
struct ChartResponseDTO: Decodable {
    let chartIndex: Int?
    let chartName: String?
    let chartType: String
    /// Arbitrary JSON subtree containing the chart's data arrays.
    let data: AnyJSON?
    /// Arbitrary JSON subtree containing the field label names.
    let metrics: AnyJSON?
    let page: Int?
    let preview: Bool?
    let status: String?
    let totalPages: Int?
    let totalPoints: Int?
}
 
// MARK: - AnyJSON
 
/// Captures an arbitrary JSON subtree as raw `Data`.
///
/// Because `Decoder` cannot hand us the raw bytes directly, `AnyJSON` routes through
/// the `JSONValue` recursive enum to reconstruct an `Any`-typed tree, then serialises
/// it back to `Data` via `JSONSerialization`. This round-trip is lossless for the
/// object/array/string/number/bool/null types the microservice uses.
struct AnyJSON: Decodable {
    /// Raw JSON bytes, deserialise with `JSONSerialization.jsonObject(with:)` when needed.
    let raw: Data
 
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(JSONValue.self) {
            self.raw = (try? JSONSerialization.data(withJSONObject: value.toAny(), options: [])) ?? Data()
        } else {
            self.raw = Data("null".utf8)
        }
    }
}
 
// MARK: - JSONValue (private)
 
/// Recursive `Decodable` representation of any JSON value.
/// Used internally by `AnyJSON` to decode unknown subtrees without `as? [String: Any]` casts.
private enum JSONValue: Decodable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])
 
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil()                                   { self = .null;          return }
        if let b = try? c.decode(Bool.self)                { self = .bool(b);       return }
        if let n = try? c.decode(Double.self)              { self = .number(n);     return }
        if let s = try? c.decode(String.self)              { self = .string(s);     return }
        if let a = try? c.decode([JSONValue].self)         { self = .array(a);      return }
        if let o = try? c.decode([String: JSONValue].self) { self = .object(o);     return }
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unrecognized JSON value")
    }
 
    /// Converts back to an `Any` value compatible with `JSONSerialization`.
    func toAny() -> Any {
        switch self {
        case .null:            return NSNull()
        case .bool(let b):     return b
        case .number(let n):   return n
        case .string(let s):   return s
        case .array(let a):    return a.map { $0.toAny() }
        case .object(let o):   return o.mapValues { $0.toAny() }
        }
    }
}
 
// MARK: - ChartResponseDTO + Reconstruction
 
extension ChartResponseDTO {
    /// Reconstructs the JSON string that `ChartConfigParser.parse(from:)` /
    /// `ChartConfigParser.parseSuggestion(configJSON:previewJSON:)` expect.
    ///
    /// The parser was designed around the mock JSON format, which includes
    /// `chartIndex`, `chartName`, `chartType`, `data`, and `metrics` at the root.
    /// This method assembles those same fields from the DTO so the live API
    /// path can reuse the existing parser without modification.
    ///
    /// - Returns: A compact JSON string, or `nil` if serialisation fails.
    func toJSONString() -> String? {
        var obj: [String: Any] = ["chartType": chartType]
        if let chartIndex   { obj["chartIndex"]   = chartIndex   }
        if let chartName    { obj["chartName"]    = chartName    }
        if let page         { obj["page"]         = page         }
        if let preview      { obj["preview"]      = preview      }
        if let status       { obj["status"]       = status       }
        if let totalPages   { obj["totalPages"]   = totalPages   }
        if let totalPoints  { obj["totalPoints"]  = totalPoints  }
        if let data,    let d = try? JSONSerialization.jsonObject(with: data.raw)    { obj["data"]    = d }
        if let metrics, let m = try? JSONSerialization.jsonObject(with: metrics.raw) { obj["metrics"] = m }
 
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: obj, options: []),
            let string   = String(data: jsonData, encoding: .utf8)
        else { return nil }
        return string
    }
}
