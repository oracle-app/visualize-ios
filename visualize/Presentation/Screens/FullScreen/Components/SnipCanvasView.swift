//
//  SnipCanvasView.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//

import SwiftUI

// MARK: - Annotation canvas

/// Canvas layer that renders committed and in-progress snip annotations over the chart image.
struct AnnotationCanvasView: View {
    var model: SnipScreenViewModel

    var body: some View {
        ZStack {
            Canvas { ctx, _ in
                for stroke in model.strokes { drawStroke(stroke, in: ctx) }
                if let live = model.liveStroke { drawStroke(live, in: ctx) }
                for shape in model.shapeAnnotations { drawShape(shape, in: ctx) }
                if let live = model.liveShape { drawShape(live, in: ctx) }
            }
            .allowsHitTesting(false)

            ForEach(model.textAnnotations) { ann in
                Text(ann.text)
                    .font(.system(size: ann.fontSize, weight: .semibold))
                    .foregroundStyle(ann.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.75))
                    .clipShape(.rect(cornerRadius: 4))
                    .shadow(color: .black.opacity(0.15), radius: 2)
                    .position(ann.position)
                    .allowsHitTesting(false)
            }

            if model.activeTool == .eraser, let last = model.liveStroke?.points.last {
                Circle()
                    .stroke(Color.gray.opacity(0.6), lineWidth: 1.5)
                    .frame(width: model.eraserRadius * 2, height: model.eraserRadius * 2)
                    .position(last)
                    .allowsHitTesting(false)
            }

            if model.activeTool == .crop {
                Canvas { ctx, size in
                    if let rect = model.liveCropRect, rect.width > 0, rect.height > 0 {
                        var outer = Path(CGRect(origin: .zero, size: size))
                        outer.addRect(rect)
                        ctx.fill(outer, with: .color(.black.opacity(0.42)), style: FillStyle(eoFill: true))
                        ctx.stroke(Path(rect), with: .color(.white),
                                   style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        for corner in corners(of: rect) {
                            ctx.fill(Path(ellipseIn: CGRect(x: corner.x - 4, y: corner.y - 4,
                                                            width: 8, height: 8)),
                                     with: .color(.white))
                        }
                    } else {
                        ctx.fill(Path(CGRect(origin: .zero, size: size)),
                                 with: .color(.black.opacity(0.15)))
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .mask {
            Canvas { ctx, size in
                if let rect = model.cropRect {
                    ctx.fill(Path(rect), with: .color(.black))
                } else {
                    ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
                }
            }
        }
    }

    private func drawStroke(_ stroke: DrawingStroke, in ctx: GraphicsContext) {
        guard stroke.points.count >= 2 else {
            if let firstPoint = stroke.points.first {
                var dot = Path()
                dot.addEllipse(in: CGRect(x: firstPoint.x - stroke.lineWidth / 2,
                                          y: firstPoint.y - stroke.lineWidth / 2,
                                          width: stroke.lineWidth,
                                          height: stroke.lineWidth))
                ctx.fill(dot, with: .color(stroke.color))
            }
            return
        }
        var path = Path()
        path.move(to: stroke.points[0])
        stroke.points.dropFirst().forEach { path.addLine(to: $0) }
        ctx.stroke(path, with: .color(stroke.color),
                   style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round))
    }

    private func drawShape(_ shape: ShapeAnnotation, in ctx: GraphicsContext) {
        let startPt = shape.startPoint
        let endPt = shape.endPoint
        let rect = CGRect(x: min(startPt.x, endPt.x), y: min(startPt.y, endPt.y),
                          width: abs(endPt.x - startPt.x), height: abs(endPt.y - startPt.y))
        guard rect.width > 0 || rect.height > 0 else { return }

        var path = Path()
        switch shape.type {
        case .line:
            path.move(to: startPt); path.addLine(to: endPt)
        case .arrow:
            path.move(to: startPt); path.addLine(to: endPt)
            let angle = atan2(endPt.y - startPt.y, endPt.x - startPt.x)
            let len: CGFloat = max(12, shape.lineWidth * 4)
            let spread: CGFloat = .pi / 6
            path.move(to: endPt)
            path.addLine(to: CGPoint(x: endPt.x - len * cos(angle - spread),
                                     y: endPt.y - len * sin(angle - spread)))
            path.move(to: endPt)
            path.addLine(to: CGPoint(x: endPt.x - len * cos(angle + spread),
                                     y: endPt.y - len * sin(angle + spread)))
        case .rectangle:
            path.addRect(rect)
        case .circle:
            path.addEllipse(in: rect)
        case .triangle:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }

        ctx.stroke(path, with: .color(shape.color),
                   style: StrokeStyle(lineWidth: shape.lineWidth, lineCap: .round, lineJoin: .round))
    }

    private func corners(of rect: CGRect) -> [CGPoint] {
        [rect.origin,
         CGPoint(x: rect.maxX, y: rect.minY),
         CGPoint(x: rect.minX, y: rect.maxY),
         CGPoint(x: rect.maxX, y: rect.maxY)]
    }
}

// MARK: - Gesture overlay

struct SnipGestureOverlayView: View {
    var model: SnipScreenViewModel

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        switch model.activeTool {
                        case .pencil:
                            if model.liveStroke == nil {
                                model.beginStroke(at: value.location)
                            } else {
                                model.continueStroke(at: value.location)
                            }
                        case .eraser:
                            if model.liveStroke == nil { model.beginErase() }
                            model.liveStroke = DrawingStroke(
                                points: [value.location], color: .clear, lineWidth: 1)
                            model.erase(at: value.location)
                        case .shape:
                            if model.liveShape == nil {
                                model.beginShape(at: value.location)
                            } else {
                                model.continueShape(to: value.location)
                            }
                        case .crop:
                            if model.liveCropRect == nil {
                                model.beginCrop(at: value.location)
                            } else {
                                model.continueCrop(to: value.location)
                            }
                        case .text:
                            break
                        }
                    }
                    .onEnded { value in
                        switch model.activeTool {
                        case .pencil: model.endStroke()
                        case .eraser: model.liveStroke = nil
                        case .shape: model.endShape()
                        case .crop: break
                        case .text:
                            let deltaX = value.location.x - value.startLocation.x
                            let deltaY = value.location.y - value.startLocation.y
                            if deltaX * deltaX + deltaY * deltaY < 144 {
                                model.pendingTextPosition = value.startLocation
                                model.draftText = ""
                                model.showTextInput = true
                            }
                        }
                    }
            )
    }
}
