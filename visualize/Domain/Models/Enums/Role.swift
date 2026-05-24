//
//  Role.swift
//  visualize
//
//  Created by Carlos Amador on 23/05/26.
//

import Foundation

enum Role: String, Codable, Sendable, Hashable {
    case admin = "ADMIN"
    case writer = "WRITER"
    case consumer = "CONSUMER"
}
