//
//  CreateVisualizationScreen.swift
//  VisualizeApp
//
//  Created by Libia Fv on 12/04/26.
//
/// Description:
/// Main view for creating data visualizations.
/// Allows the user to upload files in CSV or Excel format.
/// Displays the upload process state (uploading, completed, or idle).
/// Once the dataset is uploaded, it enables visualization generation.
/// Handles file selection using fileImporter.
/// Integrates a ViewModel to manage state logic.
/// Shows error messages when file selection or upload fails.

import SwiftUI
import UniformTypeIdentifiers

struct CreateVisualizationScreen: View {
    
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(CreateFlowState.self) private var createFlowState

    @State
    private var viewModel =
        CreateVisualizationScreenViewModel()
    
    @State private var showDeleteAlert: Bool = false

    @State
    private var isFilePickerPresented = false

    let allowedTypes: [UTType] = [
        UTType(filenameExtension: "xlsx") ?? .data,
        UTType.commaSeparatedText
    ]

    // Intro + upload area. Shared by both layouts (scrolling and anchored).
    @ViewBuilder
    private var topSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.Text.primary)
                .padding(.top, 14)
                .padding(.bottom, 16)

            Text("Create data visualizations")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppColors.Text.primary)
                .padding(.bottom, 10)
                .fixedSize(horizontal: false, vertical: true)

            Group {
                if viewModel.isUploading {
                    Text(String(localized: "Uploading your dataset..."))
                } else if viewModel.isUploadComplete {
                    Text(String(localized: "Your dataset is ready! Generate visualizations to explore your data."))
                } else {
                    Text(String(localized: "Upload a dataset and we'll generate the best visualizations to help you understand your data."))
                }
            }
            .font(.system(size: 15))
            .foregroundStyle(AppColors.Text.secondary)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 20)

            Group {
                if viewModel.isUploading {
                    UploadingFileCardView(
                        fileName: viewModel.selectedFileName ?? "",
                        fileSize: viewModel.fileSize,
                        progress: viewModel.uploadProgress,
                        onCancel: { viewModel.cancelUpload() }
                    )
                } else if viewModel.isUploadComplete {
                    CompletedFileCardView(
                        fileName: viewModel.selectedFileName ?? "",
                        fileSize: viewModel.fileSize,
                        onDelete: { showDeleteAlert = true }
                    )
                } else {
                    // Drop zone needs a min height so the dashed rectangle
                    // stays large enough for its icon + multi-line copy.
                    Button {
                        isFilePickerPresented = true
                    } label: {
                        UploadDropZoneView()
                    }
                    .buttonStyle(.plain)
                    .frame(minHeight: 160)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.isUploading)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isUploadComplete)
            .padding(.bottom, 8)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.Status.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)
            }
        }
        .padding(.horizontal, 20)
    }

    var body: some View {
        Group {
            if viewModel.isUploadComplete {
                // Upload complete: keep the action button anchored at the bottom.
                VStack(alignment: .leading, spacing: 0) {
                    topSection
                    Spacer()
                    GenerateVisButtonView {
                        guard let fileURL = viewModel.pickedFileURL else {
                            viewModel.errorMessage = String(localized: "Could not read the selected file.")
                            return
                        }
                        // Stores pendingFileURL and pushes .generatingVisualizations atomically.
                        createFlowState.startGeneration(with: fileURL, coordinator: coordinator)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 43)
                }
            } else {
                // Idle / uploading: intro + drop zone + example table flow together
                // inside a ScrollView so longer localized strings don't overlap.
                // GeometryReader lets the Spacer push the table to the bottom when
                // content is short, while still allowing scroll when content is tall.
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            topSection
                            Spacer(minLength: 0)
                            ExampleTableView()
                                .padding(.horizontal, 20)
                                .padding(.bottom, 32)
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
        }
        .onChange(of: createFlowState.createFlowResetID) { _, _ in
            viewModel.resetFile()
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: allowedTypes,
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                let accessed = url.startAccessingSecurityScopedResource()
                defer {
                    if accessed { url.stopAccessingSecurityScopedResource() }
                }
                viewModel.handleFile(url: url)
            case .failure(let error):
                viewModel.errorMessage = String(localized: "Error selecting file: \(error.localizedDescription)")
            }
        }
        .alert("Delete dataset?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.resetFile()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove the uploaded dataset.")
        }
        .portraitOrientationLock()
        .background(Color.appBackground.ignoresSafeArea())
    }
}
// MARK: - Preview

#Preview {
    CreateVisualizationScreen()
        .environment(AppCoordinator())
}
