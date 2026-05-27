//
//  DateExtensions.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let seconds = Int(Date().timeIntervalSince(self))
        switch seconds {
        case ..<60: return "just now"
        case ..<3600: return "\(seconds / 60) min ago"
        case ..<86400: return "\(seconds / 3600)h"
        default: return "\(seconds / 86400) days ago"
        }
    }
}



// TODO: Faltan weeks, months, years
// Pasando 7 días que sean a week ago
// Paso al 8vo día es la fecha exacta

// TODO: PARA REPLIES
// h d w


// TODO: PONER EL ON BACK PARA QUE NO SE QUEDE EN EL FEED

// TODO: QUE NO SALGA EL THREAD EN EL SCREENSHOT PREVENTER
