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
        let minutes = seconds / 60
        let hours = seconds / 3600
        let days = seconds / 86400
        
        switch seconds {
        case ..<60:
            return "just now"
        case ..<3600:
            return "\(minutes) min ago"
        case ..<86400:
            return "\(hours)h ago"
        case ..<(7 * 86400):
            return "\(days) days ago"
        case ..<(8 * 86400):
            return "a week ago"
        default:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: self)
        }
    }
    
    func timeAgoShort() -> String {
        let seconds = Int(Date().timeIntervalSince(self))
        let minutes = seconds / 60
        let hours = seconds / 3600
        let days = seconds / 86400
        let weeks = days / 7

        switch seconds {
        case ..<60:
            return "just now"
        case ..<3600:
            return "\(minutes)m"
        case ..<86400:
            return "\(hours)h"
        case ..<(7 * 86400):
            return "\(days)d"
        default:
            return "\(weeks)w"
        }
    }

}
