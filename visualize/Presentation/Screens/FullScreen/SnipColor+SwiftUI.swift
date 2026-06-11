//
//  SnipColor+SwiftUI.swift
//  visualize
//
//  Created by Nicolas Peralta on 01/06/26.
//

import SwiftUI
import UIKit

extension SnipColor {
    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension Color {
    var snipColor: SnipColor {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 1

        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &opacity) {
            return SnipColor(red: red, green: green, blue: blue, opacity: opacity)
        }

        var white: CGFloat = 0
        if uiColor.getWhite(&white, alpha: &opacity) {
            return SnipColor(red: white, green: white, blue: white, opacity: opacity)
        }

        return SnipColor(red: 0, green: 0, blue: 0, opacity: 1)
    }
}
