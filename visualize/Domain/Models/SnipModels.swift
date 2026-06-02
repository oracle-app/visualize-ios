//
//  SnipModels.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//
//  Domain models for Snipping Tool annotations. These lightweight value types
//  describe tools, strokes, text labels, and shapes independently from the
//  SwiftUI views that render or edit them.

import Foundation
import CoreGraphics

// MARK: - Drawing tool

/// Represents the active annotation tool in the snipping editor.
enum DrawingTool: String, CaseIterable {
    case pencil = "pencil"
    case eraser = "eraser"
    case text   = "textformat"
    case shape  = "rectangle"
    case crop   = "crop"

    /// Human-readable label used for accessibility and button titles.
    var label: String {
        switch self {
        case .pencil: return "Pencil"
        case .eraser: return "Eraser"
        case .text:   return "Text"
        case .shape:  return "Shape"
        case .crop:   return "Crop"
        }
    }
}

// MARK: - Shape type

/// The geometric shape used when drawing a shape annotation.
enum ShapeType: CaseIterable {
    case arrow, line, triangle, rectangle, circle

    /// SF Symbol name representing this shape in the UI.
    var icon: String {
        switch self {
        case .arrow:     return "arrow.up.right"
        case .line:      return "minus"
        case .triangle:  return "triangle"
        case .rectangle: return "rectangle"
        case .circle:    return "circle"
        }
    }

    /// Human-readable label used for accessibility and button titles.
    var label: String {
        switch self {
        case .arrow:     return "Arrow"
        case .line:      return "Line"
        case .triangle:  return "Triangle"
        case .rectangle: return "Rectangle"
        case .circle:    return "Circle"
        }
    }
}

// MARK: - Snip color

/// UI-independent RGBA colour value used by snip annotations.
struct SnipColor: Equatable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var opacity: CGFloat
}

// MARK: - Drawing stroke

/// A freehand pencil or eraser stroke recorded as an ordered sequence of canvas points.
struct DrawingStroke: Identifiable {
    let id = UUID()
    /// Ordered canvas coordinates that define the stroke path.
    var points: [CGPoint]
    /// Stroke colour.
    var color: SnipColor
    /// Stroke width in points.
    var lineWidth: CGFloat
}

// MARK: - Shape annotation

/// A geometric shape drawn between two canvas points.
struct ShapeAnnotation: Identifiable {
    let id = UUID()
    /// The geometric shape variant.
    var type: ShapeType
    /// The origin point where the user began drawing.
    var startPoint: CGPoint
    /// The point where the user finished drawing.
    var endPoint: CGPoint
    /// Stroke colour.
    var color: SnipColor
    /// Stroke width in points.
    var lineWidth: CGFloat
}

// MARK: - Text annotation

/// A text label placed at a specific position on the canvas.
struct TextAnnotation: Identifiable {
    let id = UUID()
    /// The display string.
    var text: String
    /// The centre position of the label on the canvas.
    var position: CGPoint
    /// Text colour.
    var color: SnipColor
    /// Font size in points.
    var fontSize: CGFloat
}
