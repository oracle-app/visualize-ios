//
//  CreateVisualizationView.swift
//  VisualizeApp
//
//  Created by Libia Fv on 12/04/26.
//
// Description:
// Main view for creating data visualizations.
// Allows the user to upload files in CSV or Excel format.
// Displays the upload process state (uploading, completed, or idle).
// Once the dataset is uploaded, it enables visualization generation.
// Handles file selection using fileImporter.
// Integrates a ViewModel to manage state logic.
// Shows error messages when file selection or upload fails.

import SwiftUI
import UniformTypeIdentifiers

struct CreateVisualization: View {
    
    @Environment(AppCoordinator.self) private var coordinator

    @State
    private var viewModel =
        CreateVisualizationViewModel()

    @State
    private var isFilePickerPresented = false

    let allowedTypes: [UTType] = [
        UTType(filenameExtension: "xlsx") ?? .data,
        UTType.commaSeparatedText
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 36))
                        .foregroundColor(.primary)
                        .padding(.top, 14)
                        .padding(.bottom, 16)

                    Text("Create data visualizations")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.bottom, 10)

                    Group {
                        if viewModel.isUploading {
                            Text("Uploading your dataset...")
                        } else if viewModel.isUploadComplete {
                            Text("Your dataset is ready! Generate visualizations to explore your data.")
                        } else {
                            Text("Upload a dataset and we'll generate the best visualizations to help you understand your data.")
                        }
                    }
                    .font(.system(size: 15))
                    .foregroundColor(Color.appSubtitle)
                    .lineSpacing(3)
                    .padding(.bottom, 20)

                    ZStack {
                        if viewModel.isUploading {
                            UploadingFileCard(
                                fileName: viewModel.selectedFileName ?? "",
                                fileSize: viewModel.fileSize,
                                progress: viewModel.uploadProgress,
                                onCancel: { viewModel.cancelUpload() }
                            )
                        } else if viewModel.isUploadComplete {
                            CompletedFileCard(
                                fileName: viewModel.selectedFileName ?? "",
                                fileSize: viewModel.fileSize,
                                onDelete: { viewModel.resetFile() }
                            )
                        } else {
                            Button {
                                isFilePickerPresented = true
                            } label: {
                                UploadDropZone()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 8)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal, 20)
            }

            VStack(alignment: .leading, spacing: 0) {
                if viewModel.isUploadComplete {
                    GenerateVisButton {
                        // TODO: Remove this mock trigger — replace with real generation call when microservice is connected
                        coordinator.push(.generatingVisualizations)
                    }
                    .padding(.bottom, 43)
                } else {
                    ExampleTable()
                        .padding(.bottom, 32)
                }
            }
            .padding(.horizontal, 20)
            .background(Color(.systemBackground))
        }
        .onChange(of: coordinator.createFlowResetID) { _, _ in
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
                viewModel.errorMessage = "Error selecting file: \(error.localizedDescription)"
            }
        }
        .onAppear {
            AppDelegate.orientationLock = .portrait
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
        .onDisappear {
            AppDelegate.orientationLock = .all
        }
    }
}

// MARK: - Preview

#Preview {
    CreateVisualization()
        .environment(AppCoordinator())
}
