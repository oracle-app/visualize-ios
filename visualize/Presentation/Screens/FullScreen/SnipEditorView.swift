import SwiftUI

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

    // MARK: - Body

    var body: some View {
        @Bindable var bindable = model

        NavigationStack {
        ZStack {
            Color.clear
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
        }
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
