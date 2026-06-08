//
//  DateExtensions.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation

extension Date {
    /// Formats the date relatively using descriptive terms, optimized for notifications.
    /// Fully modernized for iOS 26 using native format styles.
    ///
    /// This method evaluates the elapsed time from the date object to the current moment:
    /// - Less than 60 seconds: Intercepted via Calendar to force a localized "Just now".
    /// - Between 1 minute and 7 days: Uses natural terms like "yesterday" or "3 hours ago" via `.named` style.
    /// - More than 7 days: Displays the absolute date in an abbreviated format (e.g., *Jun 4, 2026*).
    ///
    /// - Returns: A localized, formatted `String` ready to be displayed in the UI.
    func relativeFormatted() -> String {
        let now = Date()
        
        let components = Calendar.current.dateComponents([.second, .minute], from: self, to: now)
        if let seconds = components.second, seconds < 60, (components.minute ?? 0) == 0 {
            return String(localized: "just_now", defaultValue: "Just now", comment: "Label displayed when content was just posted")

        }
        
        let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        if self < oneWeekAgo {
            return self.formatted(date: .abbreviated, time: .omitted)
        }
        
        return self.formatted(
            .relative(
                presentation: .named,
                unitsStyle: .wide
            )
        )
    }
    /// Formats the date using a full-length numeric relative style, ideal for standard comment rows.
    /// Fully modernized using the declarative `Date.RelativeFormatStyle` API.
    ///
    /// Performs a precise calculation based on the current device calendar components:
    /// - Less than 60 seconds: Returns "Just now" (localized).
    /// - Between 1 minute and less than 1 week: Returns numeric strings like "2 minutes ago" or "3 days ago".
    /// - 1 week or more: Returns the system's abbreviated absolute date (e.g., *Jun 4, 2026*).
    ///
    /// - Returns: A localized descriptive `String` of the elapsed time.
    func timeAgoDisplay() -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.second, .minute, .hour, .day, .weekOfYear], from: self, to: now)
        
        if let seconds = components.second, seconds < 60, (components.minute ?? 0) == 0 {
            return String(localized: "just_now", defaultValue: "Just now", comment: "Short label for less than a minute ago.")
        }
        
        if let weeks = components.weekOfYear, weeks >= 1 {
            return self.formatted(date: .abbreviated, time: .omitted)
        }
        
        return self.formatted(
            .relative(
                presentation: .numeric,
                unitsStyle: .wide
            )
        )
    }
    /// Generates an ultra-compact representation of elapsed time, designed for tight UI spaces (e.g., thread reply rows).
    /// Optimized using Calendar components to guarantee calendar accuracy while preserving custom outputs.
    ///
    /// The final output concatenates the integer numerical value with its corresponding abbreviated unit:
    /// - Less than 60 seconds: "Just now"
    /// - Minutes: `5m`
    /// - Hours: `3h`
    /// - Days: `2d`
    /// - Weeks: `4w`
    ///
    /// All structural unit strings (`m`, `h`, `d`, `w`) are handled via localization keys for multi-language support.
    ///
    /// - Returns: A compact formatted `String` (e.g., "15m", "2d").
    func timeAgoShort() -> String {
        let now = Date()
        
        let components = Calendar.current.dateComponents(
            [.second, .minute, .hour, .day, .weekOfYear],
            from: self,
            to: now
        )
        
        let secs = components.second ?? 0
        let minutes = components.minute ?? 0
        let hours = components.hour ?? 0
        let days = components.day ?? 0
        let weeks = components.weekOfYear ?? 0
        
        if secs < 60 && minutes == 0 {
            return String(localized: "just_now", defaultValue: "Just now", comment: "Short label for less than a minute ago.")
        }
        
        if weeks >= 1 {
            let unit = String(localized: "w_unit", defaultValue: "w", comment: "Weeks abbreviation e.g. 4w, Spanish: sem")
            return "\(weeks)\(unit)"
        } else if days >= 1 {
            let unit = String(localized: "d_unit", defaultValue: "d", comment: "Days abbreviation e.g. 2d")
            return "\(days)\(unit)"
        } else if hours >= 1 {
            let unit = String(localized: "h_unit", defaultValue: "h", comment: "Hours abbreviation e.g. 3h")
            return "\(hours)\(unit)"
        } else {
            let unit = String(localized: "m_unit", defaultValue: "m", comment: "Minutes abbreviation e.g. 5m")
            return "\(minutes)\(unit)"

        }
    }
}
