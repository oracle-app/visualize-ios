//
//  SnipCaptureLog.swift
//  visualize
//
//  Created by Nicolas Peralta on 13/05/26.
//
//
//  OSLog categories for the Snipping Tool capture pipeline. Centralizes the
//  subsystem/category values used while grabbing the chart viewport image so
//  capture logs stay consistent across call sites.

import os.log

/// Logging subsystem and category constants for the Snip capture flow.
enum SnipCaptureLog {
    static let general = OSLog(
        subsystem: "com.visualize.snip-capture",
        category: "viewport"
    )
}
