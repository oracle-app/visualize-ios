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
            ZStack {
                Image(uiImage: chartImage)
                    .resizable()
                    .scaledToFill()
                    .clipped()

                AnnotationCanvasView(model: model)
                SnipGestureOverlayView(model: model)
            }
            .containerRelativeFrame([.horizontal, .vertical])
            .onGeometryChange(for: CGSize.self) { $0.size } action: { canvasSize = $1 }
            .ignoresSafeArea()

            if openPanel != nil {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) { openPanel = nil }
                    }
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    UndoRedoPill(
                        canUndo: model.canUndo,
                        canRedo: model.canRedo,
                        onUndo: { model.undo() },
                        onRedo: { model.redo() }
                    )

                    Spacer()

                    SnipActionButtons(
                        onCancel: { showDiscardAlert = true },
                        onConfirm: { showPostAlert = true }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

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
        .preferredColorScheme(.light)
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
            if model.activeTool == .crop && model.liveCropRect != nil {
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
        onPost(exported)
        onDismiss()
    }
}
