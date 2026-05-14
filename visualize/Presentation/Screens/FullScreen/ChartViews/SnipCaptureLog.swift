//
//  SnipCaptureLog.swift
//  visualize
//
//  Created by SDD Apply on 13/05/26.
//

import os.log

/// Logging subsystem and category constants for the Snip capture flow.
enum SnipCaptureLog {
    static let general = OSLog(
        subsystem: "com.visualize.snip-capture",
        category: "viewport"
    )
}
