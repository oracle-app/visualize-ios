//
//  ChartOption.swift
//  visualize
//
//  Created by Nicolás Peralta on 15/04/26.
//

import Foundation

/// A chart visualization option generated from the user's dataset.
struct ChartOption: Identifiable {
    let id: UUID
    var title: String
    /// Display name of the team member who triggered the generation.
    let author: String
    /// Date on which the chart was generated.
    let date: Date

    /// Creates a new `ChartOption`.
    /// - Parameters:
    ///   - title: Chart title shown to the user (editable).
    ///   - author: Name of the generating user.
    ///   - date: Generation date; defaults to the current date and time.
    init(title: String, author: String, date: Date = .now) {
        id = UUID()
        self.title = title
        self.author = author
        self.date = date
    }
}
