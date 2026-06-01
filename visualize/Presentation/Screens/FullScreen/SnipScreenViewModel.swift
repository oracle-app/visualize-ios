//
//  SnipViewModel.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//
//  State coordinator for the Snipping Tool editor. It owns annotation arrays,
//  active tool selection, crop state, eraser behavior, and undo/redo snapshots
//  while keeping rendering details in the SwiftUI canvas layer.

import SwiftUI
import Observation

// MARK: - SnipViewModel

/// Manages drawing, text, shape, crop, erase, and undo state for the snipping editor.
@Observable
@MainActor
final class SnipScreenViewModel {

    // MARK: - State properties

    var strokes: [DrawingStroke] = []
    var liveStroke: DrawingStroke?
    var textAnnotations: [TextAnnotation] = []
    var shapeAnnotations: [ShapeAnnotation] = []
    var liveShape: ShapeAnnotation?

    var activeTool: DrawingTool = .pencil
    var activeShape: ShapeType = .rectangle
    var pencilColor: Color = .primaryOrange
    var pencilWidth: CGFloat = 3
    var eraserRadius: CGFloat = 18

    var pendingTextPosition: CGPoint?
    var showTextInput: Bool = false
    var draftText: String = ""

    var cropRect: CGRect?
    var liveCropRect: CGRect?

    var isCropInProgress: Bool { activeTool == .crop && liveCropRect != nil }

    private(set) var canUndo: Bool = false
    private(set) var canRedo: Bool = false

    // MARK: - Private properties

    private struct Snapshot {
        var strokes: [DrawingStroke]
        var annotations: [TextAnnotation]
        var shapes: [ShapeAnnotation]
        var cropRect: CGRect?
    }

    /// Maximum number of undo snapshots retained to bound memory growth.
    private let maxUndoSnapshots = 50

    private var undoStack: [Snapshot] = []
    private var redoStack: [Snapshot] = []
    private var cropStart: CGPoint?

    // MARK: - Undo / Redo

    private func saveSnapshot() {
        undoStack.append(Snapshot(strokes: strokes, annotations: textAnnotations,
                                  shapes: shapeAnnotations, cropRect: cropRect))
        if undoStack.count > maxUndoSnapshots {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
        canUndo = true
        canRedo = false
    }

    /// Reverts the canvas to the state before the last recorded action.
    ///
    /// Pushes the current state onto the redo stack before applying the previous snapshot.
    /// Has no effect if the undo stack is empty.
    func undo() {
        guard let snap = undoStack.popLast() else { return }
        redoStack.append(Snapshot(strokes: strokes, annotations: textAnnotations,
                                  shapes: shapeAnnotations, cropRect: cropRect))
        if redoStack.count > maxUndoSnapshots {
            redoStack.removeFirst()
        }
        apply(snap)
        canUndo = !undoStack.isEmpty
        canRedo = true
    }

    /// Reapplies the most recently undone action.
    ///
    /// Pushes the current state onto the undo stack before applying the redo snapshot.
    /// Has no effect if the redo stack is empty.
    func redo() {
        guard let snap = redoStack.popLast() else { return }
        undoStack.append(Snapshot(strokes: strokes, annotations: textAnnotations,
                                  shapes: shapeAnnotations, cropRect: cropRect))
        apply(snap)
        canUndo = true
        canRedo = !redoStack.isEmpty
    }

    private func apply(_ snap: Snapshot) {
        strokes = snap.strokes
        textAnnotations = snap.annotations
        shapeAnnotations = snap.shapes
        cropRect = snap.cropRect
    }

    // MARK: - Stroke

    /// Starts a new pencil stroke at the given point.
    ///
    /// - Parameters:
    ///   - point: The canvas coordinate where the stroke begins.
    func beginStroke(at point: CGPoint) {
        liveStroke = DrawingStroke(points: [point], color: pencilColor, lineWidth: pencilWidth)
    }

    /// Appends a point to the in-progress stroke.
    ///
    /// - Parameters:
    ///   - point: The next canvas coordinate along the stroke path.
    func continueStroke(at point: CGPoint) { liveStroke?.points.append(point) }

    /// Finalises the in-progress stroke and commits it to the canvas.
    ///
    /// Strokes with fewer than two points are discarded. A snapshot is saved before committing.
    func endStroke() {
        if let stroke = liveStroke, stroke.points.count > 1 {
            saveSnapshot()
            strokes.append(stroke)
        }
        liveStroke = nil
    }

    // MARK: - Eraser

    /// Saves a snapshot before erasing begins so the operation can be undone.
    func beginErase() { saveSnapshot() }

    /// Removes the portions of strokes within the eraser radius and clears any
    /// shapes or text annotations whose anchor falls inside the erase area.
    ///
    /// For strokes, the eraser performs a segment-level erase: each stroke is
    /// scanned point-by-point and split into one or more sub-strokes around the
    /// erased region, preserving the unaffected segments. Shapes and text are
    /// still removed as a whole when hit (see follow-up changes for parametric
    /// shape splitting).
    ///
    /// - Parameters:
    ///   - point: The canvas coordinate used as the centre of the erase radius.
    func erase(at point: CGPoint) {
        strokes = strokes.flatMap { stroke -> [DrawingStroke] in
            splitStroke(stroke, erasingAround: point, radius: eraserRadius)
        }
        shapeAnnotations.removeAll {
            let mid = CGPoint(x: ($0.startPoint.x + $0.endPoint.x) / 2,
                              y: ($0.startPoint.y + $0.endPoint.y) / 2)
            let deltaX = mid.x - point.x
            let deltaY = mid.y - point.y
            return deltaX * deltaX + deltaY * deltaY <= eraserRadius * eraserRadius * 4
        }
        textAnnotations.removeAll {
            let deltaX = $0.position.x - point.x
            let deltaY = $0.position.y - point.y
            return deltaX * deltaX + deltaY * deltaY <= eraserRadius * eraserRadius * 4
        }
    }

    /// Splits a stroke into the sub-strokes that survive an erase pass.
    ///
    /// Walks the stroke's points in order; any point falling inside the erase
    /// circle is dropped and acts as a cut, ending the current sub-stroke and
    /// starting a new one. Sub-strokes are preserved as long as they have at
    /// least one surviving point so single-point dots remain visible.
    ///
    /// - Parameters:
    ///   - stroke: The stroke being scanned.
    ///   - point: The centre of the erase circle in canvas coordinates.
    ///   - radius: The erase radius in points.
    /// - Returns: Zero or more sub-strokes that inherit the original stroke's
    ///   colour and line width.
    private func splitStroke(_ stroke: DrawingStroke,
                             erasingAround point: CGPoint,
                             radius: CGFloat) -> [DrawingStroke] {
        let radiusSquared = radius * radius
        var result: [DrawingStroke] = []
        var segment: [CGPoint] = []

        func flushSegment() {
            guard !segment.isEmpty else { return }
            result.append(DrawingStroke(points: segment,
                                        color: stroke.color,
                                        lineWidth: stroke.lineWidth))
            segment = []
        }

        func squaredDistance(from p: CGPoint, toSegment a: CGPoint, b: CGPoint) -> CGFloat {
            let abX = b.x - a.x
            let abY = b.y - a.y
            let apX = p.x - a.x
            let apY = p.y - a.y

            let abLen2 = abX * abX + abY * abY
            if abLen2 == 0 {
                return apX * apX + apY * apY
            }

            let t = max(0, min(1, (apX * abX + apY * abY) / abLen2))
            let closestX = a.x + t * abX
            let closestY = a.y + t * abY
            let dx = p.x - closestX
            let dy = p.y - closestY
            return dx * dx + dy * dy
        }

        let points = stroke.points
        guard !points.isEmpty else { return [] }

        for index in points.indices {
            let candidate = points[index]
            let deltaX = candidate.x - point.x
            let deltaY = candidate.y - point.y
            let isInside = deltaX * deltaX + deltaY * deltaY <= radiusSquared

            if index == points.startIndex {
                if !isInside {
                    segment = [candidate]
                }
                continue
            }

            let prev = points[points.index(before: index)]
            let segmentIntersects = squaredDistance(from: point, toSegment: prev, b: candidate) <= radiusSquared

            if isInside || segmentIntersects {
                // Cut the stroke here and ensure we don't keep the visual bridge across the erased segment.
                flushSegment()
                if !isInside {
                    segment = [candidate]
                }
            } else {
                if segment.isEmpty {
                    segment = [candidate]
                } else {
                    segment.append(candidate)
                }
            }
        }
        flushSegment()

        return result
    }

    // MARK: - Shape

    /// Starts drawing a shape annotation from the given point.
    ///
    /// - Parameters:
    ///   - point: The canvas coordinate where the shape originates.
    func beginShape(at point: CGPoint) {
        liveShape = ShapeAnnotation(type: activeShape, startPoint: point, endPoint: point,
                                    color: pencilColor, lineWidth: pencilWidth)
    }

    /// Updates the end point of the in-progress shape as the user drags.
    ///
    /// - Parameters:
    ///   - point: The current drag position on the canvas.
    func continueShape(to point: CGPoint) { liveShape?.endPoint = point }

    /// Finalises the in-progress shape and commits it to the canvas.
    ///
    /// Shapes smaller than 10 × 10 points (distance² < 100) are discarded.
    /// A snapshot is saved before committing.
    func endShape() {
        if let shape = liveShape {
            let deltaX = shape.endPoint.x - shape.startPoint.x
            let deltaY = shape.endPoint.y - shape.startPoint.y
            if deltaX * deltaX + deltaY * deltaY > 100 {
                saveSnapshot()
                shapeAnnotations.append(shape)
            }
        }
        liveShape = nil
    }

    // MARK: - Text

    /// Commits the current draft text as a text annotation at `pendingTextPosition`.
    ///
    /// Silently discards the draft if it is empty, blank, or if no position is pending.
    /// A snapshot is saved before the annotation is added.
    func commitText() {
        guard let pos = pendingTextPosition,
              !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            pendingTextPosition = nil
            draftText = ""
            return
        }
        saveSnapshot()
        textAnnotations.append(TextAnnotation(text: draftText, position: pos,
                                              color: pencilColor, fontSize: 16))
        pendingTextPosition = nil
        draftText = ""
    }

    // MARK: - Crop

    /// Starts a crop selection from the given point.
    ///
    /// - Parameters:
    ///   - point: The canvas coordinate where the crop rectangle originates.
    func beginCrop(at point: CGPoint) {
        cropStart = point
        liveCropRect = CGRect(origin: point, size: .zero)
    }

    /// Updates the live crop rectangle as the user drags.
    ///
    /// - Parameters:
    ///   - point: The current drag position defining the opposite corner of the crop rectangle.
    func continueCrop(to point: CGPoint) {
        guard let start = cropStart else { return }
        liveCropRect = CGRect(x: min(start.x, point.x), y: min(start.y, point.y),
                              width: abs(point.x - start.x), height: abs(point.y - start.y))
    }

    /// Commits the live crop rectangle as the active crop mask.
    ///
    /// Rectangles smaller than 10 × 10 points are discarded and `cancelCrop()` is called instead.
    /// A snapshot is saved before the crop is applied.
    func applyCrop() {
        guard let rect = liveCropRect, rect.width > 10, rect.height > 10 else {
            cancelCrop()
            return
        }
        saveSnapshot()
        cropRect = rect
        liveCropRect = nil
        cropStart = nil
        activeTool = .pencil
    }

    /// Discards the in-progress crop selection and resets the active tool to pencil.
    func cancelCrop() {
        liveCropRect = nil
        cropStart = nil
        activeTool = .pencil
    }

    /// Clears all annotations, strokes, and the crop mask from the canvas.
    ///
    /// A snapshot is saved before clearing so the operation can be undone.
    func clearAll() {
        saveSnapshot()
        strokes.removeAll()
        textAnnotations.removeAll()
        shapeAnnotations.removeAll()
        liveStroke = nil
        liveShape = nil
        cropRect = nil
        liveCropRect = nil
    }
}
