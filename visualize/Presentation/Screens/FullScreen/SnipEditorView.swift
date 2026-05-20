//
//  SnipEditorView.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//

import SwiftUI

/// Full-screen editor for cropping, annotating, and sharing a captured chart image.
struct SnipEditorView: View {

    // MARK: - State properties

    @State private var model: SnipViewModel
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
        _model = State(initialValue: SnipViewModel())
    }

    // MARK: - Crop Zoom (visual only)

    private var cropZoomScale: CGFloat {
        guard let rect = model.cropRect,
              canvasSize.width > 0, canvasSize.height > 0,
              rect.width > 0, rect.height > 0
        else { return 1 }

        return min(canvasSize.width / rect.width, canvasSize.height / rect.height)
    }

    private var cropZoomAnchor: UnitPoint {
        guard let rect = model.cropRect,
              canvasSize.width > 0, canvasSize.height > 0,
              rect.width > 0, rect.height > 0
        else { return .center }

        return UnitPoint(
            x: rect.midX / canvasSize.width,
            y: rect.midY / canvasSize.height
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

    private var isCropInProgress: Bool {
        model.activeTool == .crop && model.liveCropRect != nil
    }

    // MARK: - Body

    var body: some View {
        @Bindable var bindable = model

        NavigationStack {
        ZStack {
            Color.white
                .overlay {
                    ZStack {
                        Image(uiImage: chartImage)
                            .resizable()
                            .scaledToFit()

                        AnnotationCanvasView(model: model)
                        SnipGestureOverlayView(model: model)
                    }
                    .aspectRatio(chartImage.size, contentMode: .fit)
                    .onGeometryChange(for: CGSize.self) { proxy in proxy.size } action: { newSize in
                        guard newSize.width > 0, newSize.height > 0 else { return }
                        canvasSize = newSize
                    }
                    .mask {
                        if let rect = model.cropRect {
                            Canvas { ctx, _ in
                                ctx.fill(Path(rect), with: .color(.black))
                            }
                        } else {
                            Rectangle()
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

            FloatingControls(model: model, openPanel: $openPanel, isCropInProgress: isCropInProgress)
        }
        .onChange(of: isCropInProgress) { _, inProgress in
            if inProgress {
                withAnimation(.spring(duration: 0.22, bounce: 0.1)) { openPanel = nil }
            }
        }
        .animation(.spring(duration: 0.22, bounce: 0.1), value: isCropInProgress)
        .ignoresSafeArea()
        .preferredColorScheme(.light)
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
            TextField("Type something…", text: $bindable.draftText)
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
    }

    private struct FloatingControls: View {
        var model: SnipViewModel
        @Binding var openPanel: ToolPanel?
        let isCropInProgress: Bool

        var body: some View {
            @Bindable var bindable = model

            if !isCropInProgress {
                VStack(spacing: 0) {
                    Spacer()

                    HStack(alignment: .bottom, spacing: 0) {
                        Spacer()

                        if openPanel == .strokeWidth {
                            SnipStrokeWidthPanelView(model: bindable)
                                .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .bottom)))
                        }

                        Spacer()

                        if openPanel == .shapes {
                            SnipShapesPanelView(model: model) {
                                withAnimation(.easeOut(duration: 0.15)) { openPanel = nil }
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .bottom)))
                            .padding(.trailing, 60)
                        }
                    }
                    .padding(.bottom, 8)
                    .padding(.horizontal, 24)

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
