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
    var eraserWidth: CGFloat {
        get { eraserRadius * 2 }
        set { eraserRadius = max(1, newValue / 2) }
    }

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
    private let maxUndoSnapshots: Int = 50

    private var undoStack: [Snapshot] = []
    private var redoStack: [Snapshot] = []
    private var cropStart: CGPoint?
    /// Maximum spacing, in canvas points, allowed between consecutive pencil samples.
    /// This is intentionally local and easy to tune once the final UX distance is chosen.
    private let maxStrokePointDistance: CGFloat = 8

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
        liveStroke = DrawingStroke(points: [point], color: pencilColor.snipColor, lineWidth: pencilWidth)
    }

    /// Appends a point to the in-progress stroke, inserting interpolated samples
    /// when the drag event jumps farther than `maxStrokePointDistance`.
    ///
    /// - Parameters:
    ///   - point: The next canvas coordinate along the stroke path.
    func continueStroke(at point: CGPoint) {
        guard var stroke = liveStroke else { return }
        guard let lastPoint = stroke.points.last else {
            stroke.points = [point]
            liveStroke = stroke
            return
        }

        stroke.points.append(contentsOf: resampledPoints(from: lastPoint, to: point))
        liveStroke = stroke
    }

    /// Returns the points needed to travel from `start` to `end` without any
    /// consecutive samples exceeding `maxStrokePointDistance`.
    ///
    /// The returned array always includes `end` and excludes `start`, so callers
    /// can append it directly to an existing stroke without duplicating points.
    private func resampledPoints(from start: CGPoint, to end: CGPoint) -> [CGPoint] {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let distance = hypot(deltaX, deltaY)

        guard maxStrokePointDistance > 0, distance > maxStrokePointDistance else {
            return [end]
        }

        var points: [CGPoint] = []
        var travelled = maxStrokePointDistance

        while travelled < distance {
            let progress = travelled / distance
            points.append(CGPoint(
                x: start.x + deltaX * progress,
                y: start.y + deltaY * progress
            ))
            travelled += maxStrokePointDistance
        }

        points.append(end)
        return points
    }

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
    /// text annotations whose anchor falls inside the erase area.
    ///
    /// For strokes, the eraser performs a segment-level erase: each stroke is
    /// scanned point-by-point and split into one or more sub-strokes around the
    /// erased region, preserving the unaffected segments. Supported shapes are
    /// first sampled into stroke-like paths so line and rectangle annotations can
    /// be partially erased instead of removed as whole objects.
    ///
    /// - Parameters:
    ///   - point: The canvas coordinate used as the centre of the erase radius.
    func erase(at point: CGPoint) {
        strokes = strokes.flatMap { stroke -> [DrawingStroke] in
            splitStroke(stroke, erasingAround: point, radius: eraserRadius)
        }

        var convertedShapeStrokes: [DrawingStroke] = []
        shapeAnnotations = shapeAnnotations.compactMap { shape in
            let shapeStrokes = sampledStrokes(for: shape)

            guard !shapeStrokes.isEmpty else {
                return shouldEraseWholeShape(shape, around: point) ? nil : shape
            }

            let survivingStrokes = shapeStrokes.flatMap { stroke in
                splitStroke(stroke, erasingAround: point, radius: eraserRadius)
            }

            if strokesAreUnchanged(before: shapeStrokes, after: survivingStrokes) {
                return shape
            }

            convertedShapeStrokes.append(contentsOf: survivingStrokes)
            return nil
        }
        strokes.append(contentsOf: convertedShapeStrokes)

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

    /// Converts the supported closed/open shape variants into sampled stroke paths.
    private func sampledStrokes(for shape: ShapeAnnotation) -> [DrawingStroke] {
        let start = shape.startPoint
        let end = shape.endPoint
        let rect = CGRect(x: min(start.x, end.x), y: min(start.y, end.y),
                          width: abs(end.x - start.x), height: abs(end.y - start.y))
        guard rect.width > 0 || rect.height > 0 else { return [] }

        let paths: [[CGPoint]]
        switch shape.type {
        case .line:
            paths = [sampledPolyline([start, end])]
        case .rectangle:
            paths = [sampledPolyline([
                CGPoint(x: rect.minX, y: rect.minY),
                CGPoint(x: rect.maxX, y: rect.minY),
                CGPoint(x: rect.maxX, y: rect.maxY),
                CGPoint(x: rect.minX, y: rect.maxY),
                CGPoint(x: rect.minX, y: rect.minY)
            ])]
        case .triangle:
            paths = [sampledPolyline([
                CGPoint(x: rect.midX, y: rect.minY),
                CGPoint(x: rect.maxX, y: rect.maxY),
                CGPoint(x: rect.minX, y: rect.maxY),
                CGPoint(x: rect.midX, y: rect.minY)
            ])]
        case .arrow:
            let angle = atan2(end.y - start.y, end.x - start.x)
            let length: CGFloat = max(12, shape.lineWidth * 4)
            let spread: CGFloat = .pi / 6
            let firstHeadPoint = CGPoint(x: end.x - length * cos(angle - spread),
                                         y: end.y - length * sin(angle - spread))
            let secondHeadPoint = CGPoint(x: end.x - length * cos(angle + spread),
                                          y: end.y - length * sin(angle + spread))
            paths = [
                sampledPolyline([start, end]),
                sampledPolyline([end, firstHeadPoint]),
                sampledPolyline([end, secondHeadPoint])
            ]
        case .circle:
            paths = [sampledEllipse(in: rect)]
        }

        return paths
            .filter { $0.count > 1 }
            .map { DrawingStroke(points: $0, color: shape.color, lineWidth: shape.lineWidth) }
    }

    /// Preserves the previous whole-shape erase behavior for shape types that
    /// have not been converted to sampled paths yet.
    private func shouldEraseWholeShape(_ shape: ShapeAnnotation, around point: CGPoint) -> Bool {
        let mid = CGPoint(x: (shape.startPoint.x + shape.endPoint.x) / 2,
                          y: (shape.startPoint.y + shape.endPoint.y) / 2)
        let deltaX = mid.x - point.x
        let deltaY = mid.y - point.y
        return deltaX * deltaX + deltaY * deltaY <= eraserRadius * eraserRadius * 4
    }

    /// Returns true when an erase pass did not split or remove any sampled shape
    /// stroke, allowing the original shape annotation to keep its semantic type.
    private func strokesAreUnchanged(before original: [DrawingStroke],
                                     after erased: [DrawingStroke]) -> Bool {
        guard original.count == erased.count else { return false }

        return zip(original, erased).allSatisfy { originalStroke, erasedStroke in
            originalStroke.points == erasedStroke.points
        }
    }

    /// Samples connected line segments so neighbouring points stay close enough
    /// for future shape eraser hit-testing to split paths cleanly.
    private func sampledPolyline(_ vertices: [CGPoint]) -> [CGPoint] {
        guard let first = vertices.first else { return [] }

        var points: [CGPoint] = [first]
        for vertex in vertices.dropFirst() {
            guard let last = points.last else { continue }
            points.append(contentsOf: resampledPoints(from: last, to: vertex))
        }
        return points
    }

    /// Samples an ellipse perimeter. The first sample is the right-most point of
    /// the ellipse and the last sample returns to that same point, giving closed
    /// shapes an explicit seam for stroke splitting.
    private func sampledEllipse(in rect: CGRect) -> [CGPoint] {
        let radiusX = rect.width / 2
        let radiusY = rect.height / 2
        let circumferenceEstimate = 2 * .pi * sqrt((radiusX * radiusX + radiusY * radiusY) / 2)
        let sampleCount = max(24, Int(ceil(circumferenceEstimate / maxStrokePointDistance)))

        return (0...sampleCount).map { index in
            let angle = CGFloat(index) / CGFloat(sampleCount) * 2 * .pi
            return CGPoint(x: rect.midX + cos(angle) * radiusX,
                           y: rect.midY + sin(angle) * radiusY)
        }
    }

    // MARK: - Shape

    /// Starts drawing a shape annotation from the given point.
    ///
    /// - Parameters:
    ///   - point: The canvas coordinate where the shape originates.
    func beginShape(at point: CGPoint) {
        liveShape = ShapeAnnotation(type: activeShape, startPoint: point, endPoint: point,
                                    color: pencilColor.snipColor, lineWidth: pencilWidth)
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
                                              color: pencilColor.snipColor, fontSize: 16))
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
