//
//  SnipEditorView.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//
//
//  Main Snipping Tool screen. It presents the captured chart, hosts the
//  annotation canvas and gestures, manages crop zoom, and exports the edited
//  image when the user shares it as a new thread.

import SwiftUI

/// Full-screen editor for cropping, annotating, and sharing a captured chart image.
struct SnipEditorScreen: View {

    private static let maxCropZoomScale: CGFloat = 8

    // MARK: - State properties

    @State private var model: SnipScreenViewModel
    @State private var openPanel: ToolPanel?
    @State private var showDiscardAlert: Bool = false
    @State private var showPostAlert: Bool = false
    @State private var canvasSize: CGSize = .zero

    @Environment(\.displayScale) private var displayScale

    let chartImage: UIImage
    let onPost: (UIImage) -> Void
    let onDismiss: () -> Void

    // MARK: - Init

    init(chartImage: UIImage, onPost: @escaping (UIImage) -> Void, onDismiss: @escaping () -> Void) {
        self.chartImage = chartImage
        self.onPost = onPost
        self.onDismiss = onDismiss
        _model = State(initialValue: SnipScreenViewModel())
    }

    // MARK: - Crop Zoom (visual only)

    private var cropZoomScale: CGFloat {
        guard let rect = model.cropRect,
              canvasSize.width > 0, canvasSize.height > 0,
              rect.width > 0, rect.height > 0
        else { return 1 }

        let rawScale = min(canvasSize.width / rect.width, canvasSize.height / rect.height)
        return min(rawScale, Self.maxCropZoomScale)
    }

    private var cropZoomAnchor: UnitPoint {
        guard let rect = model.cropRect,
              canvasSize.width > 0, canvasSize.height > 0,
              rect.width > 0, rect.height > 0
        else { return .center }

        let x = min(max(rect.midX / canvasSize.width, 0), 1)
        let y = min(max(rect.midY / canvasSize.height, 0), 1)
        return UnitPoint(
            x: x,
            y: y
        )
    }

    private var cropZoomOffset: CGSize {
        guard let rect = model.cropRect,
              canvasSize.width > 0, canvasSize.height > 0,
              rect.width > 0, rect.height > 0
        else { return .zero }

        return CGSize(
            width: canvasSize.width / 2 - rect.midX,
            height: canvasSize.height / 2 - rect.midY
        )
    }

    // MARK: - Body

    var body: some View {
        @Bindable var bindable = model

        NavigationStack {
        ZStack {
            Color.appBackground
                .overlay {
                    ZStack {
                        Image(uiImage: chartImage)
                            .resizable()
                            .scaledToFit()
                            .accessibilityIdentifier("SnipChartImage")

                        AnnotationCanvasView(model: model)
                        SnipGestureOverlayView(model: model)
                    }
                    .aspectRatio(chartImage.size, contentMode: .fit)
                    .onGeometryChange(for: CGSize.self) { proxy in proxy.size } action: { newSize in
                        guard newSize.width > 0, newSize.height > 0 else { return }
                        canvasSize = newSize
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
                    .scaleEffect(cropZoomScale, anchor: cropZoomAnchor)
                    .offset(cropZoomOffset)
                    .clipped()
                    .animation(.spring(duration: 0.45, bounce: 0.18), value: model.cropRect)
                }

            if openPanel != nil {
                // Tap-outside scrim to dismiss the floating panel.
                // onTapGesture is intentional here — a Button would break
                // VoiceOver semantics for an invisible full-screen dismiss layer.
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) { openPanel = nil }
                    }
                    .ignoresSafeArea()
            }

            FloatingControls(model: model, openPanel: $openPanel, isCropInProgress: model.isCropInProgress)
        }
        .onChange(of: model.isCropInProgress) { _, inProgress in
            if inProgress {
                openPanel = nil
            }
        }
        .animation(.spring(duration: 0.22, bounce: 0.1), value: model.isCropInProgress)
        .ignoresSafeArea()
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .bottomBar)
        .alert("Discard changes?", isPresented: $showDiscardAlert) {
            Button("Discard", role: .destructive) { onDismiss() }
            Button("Continue", role: .cancel) {}
        } message: {
            Text("If you cancel, your annotations will not be saved.")
        }
        .alert("Share as new thread?", isPresented: $showPostAlert) {
            Button("Share") { exportAndPost() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This edited visualization will be shared as a new thread.")
        }
        .alert("Add text annotation", isPresented: $bindable.showTextInput) {
            TextField(String(localized: "Type something…"), text: $bindable.draftText)
                .onChange(of: bindable.draftText) { _, new in
                    if new.count > 100 { bindable.draftText = String(new.prefix(100)) }
                }
            Button("Cancel", role: .cancel) {
                bindable.draftText = ""
                bindable.pendingTextPosition = nil
            }
            Button("Add") { bindable.commitText() }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ControlGroup {
                    Button("Undo", systemImage: "arrow.uturn.backward") { model.undo() }
                        .disabled(!model.canUndo)
                    Button("Redo", systemImage: "arrow.uturn.forward") { model.redo() }
                        .disabled(!model.canRedo)
                }
                .controlGroupStyle(.navigation)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel", systemImage: "xmark") { showDiscardAlert = true }
                    .tint(Color.appNavy)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm", systemImage: "checkmark") { showPostAlert = true }
                    .tint(Color.primaryOrange)
                    .disabled(model.isCropInProgress)
            }

            if model.activeTool == .crop, model.liveCropRect != nil {
                ToolbarItem(placement: .bottomBar) {
                    Button("Cancel") { model.cancelCrop() }
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Apply Crop") { model.applyCrop() }
                        .bold()
                }
            }
        }
        } // NavigationStack
        .accessibilityIdentifier("SnipEditorScreen")
    }

    private struct FloatingControls: View {
        var model: SnipScreenViewModel
        @Binding var openPanel: ToolPanel?
        let isCropInProgress: Bool

        var body: some View {
            @Bindable var bindable = model

            if !isCropInProgress {
                VStack(spacing: 0) {
                    Spacer()

                    // Floating panels are anchored to the toolbar (which is itself
                    // horizontally centered on screen), not to the screen edges. Each
                    // panel is centered in the ZStack and then nudged with `.offset`
                    // by the horizontal distance from the toolbar's center to the
                    // center of the button that owns it. This keeps panels visually
                    // above their button in any orientation.
                    //
                    // Toolbar layout (see SnipFloatingToolbar): 7 buttons × 38pt with
                    // 2pt spacing → button-to-button stride = 40pt. The stroke-width
                    // button is the 4th of 7, sitting exactly at the toolbar's
                    // center, so its panel needs no offset. The shape button is the
                    // 6th, two strides (80pt) to the right of center.
                    ZStack {
                        if openPanel == .strokeWidth {
                            SnipStrokeWidthPanelView(model: bindable)
                                .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .bottom)))
                        }

                        if openPanel == .shapes {
                            SnipShapesPanelView(model: model) {
                                withAnimation(.easeOut(duration: 0.15)) { openPanel = nil }
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .bottom)))
                            .offset(x: SnipFloatingToolbar.panelOffset(for: .shapes))
                        }
                    }
                    .padding(.bottom, 8)

                    SnipFloatingToolbar(
                        selectedTool: $bindable.activeTool,
                        currentColor: $bindable.pencilColor,
                        openPanel: $openPanel
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .animation(.spring(duration: 0.22, bounce: 0.1), value: openPanel)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }

    // MARK: - Export

    private func exportAndPost() {
        let canvas = ZStack {
            Image(uiImage: chartImage)
                .resizable()
                .scaledToFill()
            AnnotationCanvasView(model: model)
        }
        .frame(width: canvasSize.width, height: canvasSize.height)

        let renderer = ImageRenderer(content: canvas)
        renderer.scale = displayScale
        guard let exported = renderer.uiImage else { return }

        let final: UIImage
        if let cropRect = model.cropRect,
           let cgImage = exported.cgImage {
            // cropRect is in canvas points — scale to pixel space
            let scale = exported.scale
            let pixelRect = CGRect(
                x: cropRect.origin.x * scale,
                y: cropRect.origin.y * scale,
                width: cropRect.width * scale,
                height: cropRect.height * scale
            )
            if let cropped = cgImage.cropping(to: pixelRect) {
                final = UIImage(cgImage: cropped, scale: exported.scale, orientation: exported.imageOrientation)
            } else {
                final = exported
            }
        } else {
            final = exported
        }

        onPost(final)
        onDismiss()
    }
}
