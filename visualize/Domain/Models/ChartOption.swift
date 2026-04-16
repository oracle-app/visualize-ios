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
    let author: String
    let date: String

    init(title: String, author: String, date: String) {
        id = UUID()
        self.title = title
        self.author = author
        self.date = date
    }
}
