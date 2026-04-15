//
//  CardModel.swift
//  Visualize
//
//  Created by Jorge Flores on 11/04/26.
//


import SwiftUI

struct CardModel: Identifiable {
    var id = UUID().uuidString
    var title: String
    var description: String
}
