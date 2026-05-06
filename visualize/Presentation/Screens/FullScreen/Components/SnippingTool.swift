import SwiftUI

// MARK: - Panel state

enum ToolPanel: Equatable {
    case shapes
    case strokeWidth
}

// MARK: - Undo/Redo pill

struct UndoRedoPill: View {
    let canUndo: Bool
    let canRedo: Bool
    let onUndo: () -> Void
    let onRedo: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            undoRedoButton("arrow.uturn.backward", enabled: canUndo, action: onUndo)
            undoRedoButton("arrow.uturn.forward", enabled: canRedo, action: onRedo)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
            ZStack {
                Color.white.opacity(0.65)
                RoundedRectangle(cornerRadius: 32).fill(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 32))
        }
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
    }

    @ViewBuilder
    private func undoRedoButton(
        _ name: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(name, systemImage: name, action: action)
            .labelStyle(.iconOnly)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(enabled ? Color.appNavy : Color.appNavy.opacity(0.28))
            .frame(width: 42, height: 40)
            .disabled(!enabled)
            .buttonStyle(.plain)
    }
}

// MARK: - Action buttons

struct SnipActionButtons: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button("Cancel", systemImage: "xmark", action: onCancel)
                .labelStyle(.iconOnly)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appNavy)
                .frame(width: 46, height: 46)
                .background {
                    ZStack {
                        Color.white.opacity(0.65)
                        Circle().fill(.ultraThinMaterial)
                    }
                    .clipShape(Circle())
                }
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 2)
                .buttonStyle(.plain)

            Button("Confirm", systemImage: "checkmark", action: onConfirm)
                .labelStyle(.iconOnly)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(Color.primaryOrange, in: Circle())
                .shadow(color: Color.primaryOrange.opacity(0.35), radius: 8, x: 0, y: 2)
                .buttonStyle(.plain)
        }
    }
}

// MARK: - Floating toolbar

struct SnipFloatingToolbar: View {
    @Binding var selectedTool: DrawingTool
    @Binding var currentColor: Color
    @Binding var openPanel: ToolPanel?

    private let activeIconColor = Color.appTeal
    private let activeBgColor = Color.appMint
    private let normalIconColor = Color.appNavy
    private let toolCornerRadius: CGFloat = 10
    private let containerRadius: CGFloat = 32

    var body: some View {
        HStack(spacing: 2) {
            iconToolButton(tool: .pencil, symbol: "pencil")
            iconToolButton(tool: .eraser, symbol: "eraser")
            colorSwatchButton
            strokeWeightButton
            textToolButton
            shapeToolButton
            iconToolButton(tool: .crop, symbol: "crop")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            ZStack {
                Color.white.opacity(0.65)
                RoundedRectangle(cornerRadius: containerRadius).fill(.thinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: containerRadius))
        }
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
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
        .background(isActive ? activeBgColor : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: toolCornerRadius))
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .buttonStyle(.plain)
    }
}

// MARK: - Shapes panel

struct SnipShapesPanelView: View {
    var model: SnipViewModel
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
                .background(isSelected ? Color.appMint : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background {
            ZStack {
                Color.white.opacity(0.65)
                RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 4)
    }
}

// MARK: - Stroke width panel

struct SnipStrokeWidthPanelView: View {
    @Bindable var model: SnipViewModel

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
        .background {
            ZStack {
                Color.white.opacity(0.65)
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 4)
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
