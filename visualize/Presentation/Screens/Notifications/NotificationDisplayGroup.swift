//
//  NotificationDisplayGroup.swift
//  visualize
//
//  Created by Miguel Degollado 
//

import Foundation

struct NotificationDisplayGroup: Identifiable {
    let id: String
    let items: [NotificationDisplayItem]
    var title: String { id }

    init(id: String, items: [NotificationDisplayItem]) {
        self.id = id
        self.items = items
    }
}
