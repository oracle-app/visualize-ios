//
//  SnippingTool.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//

import SwiftUI

// MARK: - Panel state

/// Floating panel currently expanded from the snipping toolbar.
enum ToolPanel: Equatable {
    case shapes
    case strokeWidth
}

// MARK: - Floating toolbar

/// Bottom floating toolbar used to select snipping annotation tools and style controls.
struct SnipFloatingToolbar: View {
    @Binding var selectedTool: DrawingTool
    @Binding var currentColor: Color
    @Binding var openPanel: ToolPanel?

    private let activeIconColor = Color.appTeal
    private let activeBgColor = Color.appMint
    private let normalIconColor = Color.appNavy
    private let toolCornerRadius: CGFloat = 10
    private let containerRadius: CGFloat = 32

    // Geometry shared with `SnipEditorView` for panel anchoring.
    // Buttons are 38pt wide with 2pt spacing → 40pt stride between centers.
    // The stroke-width button (index 3 of 7) sits at the toolbar's center.
    // Offsets below are signed horizontal distances from that center to the
    // owning button's center, used by floating panels to align over them.
    private static let buttonStride: CGFloat = 40

    /// Horizontal offset (in points) from the toolbar's center to the center
    /// of the button that opens `panel`. Keep in sync with the button order
    /// declared inside `body`.
    static func panelOffset(for panel: ToolPanel) -> CGFloat {
        switch panel {
        case .strokeWidth: return 0          // index 3 — centered
        case .shapes:      return buttonStride * 2  // index 5 — two strides right
        }
    }

    var body: some View {
        HStack(spacing: 2) {
            iconToolButton(tool: .pencil, symbol: "pencil")    // 0
            iconToolButton(tool: .eraser, symbol: "eraser")    // 1
            colorSwatchButton                                  // 2
            strokeWeightButton                                 // 3 — opens .strokeWidth
            textToolButton                                     // 4
            shapeToolButton                                    // 5 — opens .shapes
            iconToolButton(tool: .crop, symbol: "crop")        // 6
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: containerRadius))
    }

    @ViewBuilder
    private func iconToolButton(tool: DrawingTool, symbol: String) -> some View {
        let isActive = selectedTool == tool
        Button(tool.label, systemImage: symbol) {
            selectedTool = tool
            openPanel = nil
        }
        .labelStyle(.iconOnly)
        .font(.system(size: 17))
        .foregroundStyle(isActive ? activeIconColor : normalIconColor)
        .frame(width: 38, height: 38)
        .contentShape(Rectangle())
        .background(isActive ? activeBgColor : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: toolCornerRadius))
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .buttonStyle(.plain)
    }

    private var colorSwatchButton: some View {
        ColorPicker("Stroke color", selection: $currentColor, supportsOpacity: false)
            .labelsHidden()
            .frame(width: 38, height: 38)
    }

    private var strokeWeightButton: some View {
        let isOpen = openPanel == .strokeWidth
        return Button {
            openPanel = isOpen ? nil : .strokeWidth
        } label: {
            SnipStrokeWidthIcon()
                .foregroundStyle(isOpen ? activeIconColor : normalIconColor)
        }
        .frame(width: 38, height: 38)
        .contentShape(Rectangle())
        .background(isOpen ? activeBgColor : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: toolCornerRadius))
        .animation(.easeInOut(duration: 0.2), value: isOpen)
        .buttonStyle(.plain)
    }

    private var textToolButton: some View {
        let isActive = selectedTool == .text
        return Button("Text", systemImage: "textformat") {
            selectedTool = .text
            openPanel = nil
        }
        .labelStyle(.iconOnly)
        .font(.system(size: 17))
        .foregroundStyle(isActive ? activeIconColor : normalIconColor)
        .frame(width: 38, height: 38)
        .contentShape(Rectangle())
        .background(isActive ? activeBgColor : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: toolCornerRadius))
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .buttonStyle(.plain)
    }

    private var shapeToolButton: some View {
        let isActive = selectedTool == .shape
        return Button("Shape", systemImage: "square.on.square") {
            selectedTool = .shape
            openPanel = openPanel == .shapes ? nil : .shapes
        }
        .labelStyle(.iconOnly)
        .font(.system(size: 16))
        .foregroundStyle(isActive ? activeIconColor : normalIconColor)
        .frame(width: 38, height: 38)
        .contentShape(Rectangle())
        .background(isActive ? activeBgColor : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: toolCornerRadius))
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .buttonStyle(.plain)
    }
}

// MARK: - Shapes panel

struct SnipShapesPanelView: View {
    var model: SnipScreenViewModel
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            ForEach(ShapeType.allCases, id: \.label) { shape in
                let isSelected = model.activeShape == shape && model.activeTool == .shape
                Button(shape.label, systemImage: shape.icon) {
                    model.activeShape = shape
                    model.activeTool = .shape
                    onSelect()
                }
                .labelStyle(.iconOnly)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(isSelected ? Color.appTeal : Color.appNavy)
                .frame(width: 42, height: 42)
                .contentShape(Rectangle())
                .background(isSelected ? Color.appMint : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stroke width panel

struct SnipStrokeWidthPanelView: View {
    @Bindable var model: SnipScreenViewModel

    var body: some View {
        VStack(spacing: 8) {
            Text("\(Int(model.pencilWidth)) px")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appNavy)
                .monospacedDigit()

            Slider(value: $model.pencilWidth, in: 1...30, step: 1)
                .tint(Color.appTeal)
                .frame(width: 120)
                .rotationEffect(.degrees(-90))
                .frame(width: 44, height: 120)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 10)
        .frame(width: 64)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct SnipStrokeWidthIcon: View {
    var body: some View {
        VStack(spacing: 3) {
            Capsule().frame(height: 1)
            Capsule().frame(height: 2.5)
            Capsule().frame(height: 4)
        }
        .foregroundStyle(Color.appNavy)
        .frame(width: 22)
    }
}
