//
//  CreateVisualizationViewModel.swift
//  VisualizeApp
//
//  Created by Libia Fv on 14/04/26.
//
// Description:
// ViewModel responsible for managing the file upload logic for creating visualizations.
// Validates that the file is of an allowed type (.xlsx or .csv) and does not exceed the defined size limit.
// Manages the upload state, including progress, completion, and cancellation.
// Calculates and formats the file size for display in the UI.
// Uses use cases for file validation and size checking.
// Controls the simulated upload progress using a timer.
// Allows the upload process to be reset or cancelled based on user interaction.

import Foundation
import SwiftUI

@Observable
class CreateVisualizationViewModel{

    var selectedFileName: String? = nil
    var errorMessage: String? = nil

    var isUploading: Bool = false
    var uploadProgress: Double = 0.0
    var isUploadComplete: Bool = false

    var fileSize: String = "0 MB"

    private var timer: Timer?

    private let validateFileUseCase = ValidateFileUseCase()
    private let checkFileSizeUseCase = CheckFileSizeUseCase()


    func handleFile(url: URL) {

        guard validateFileUseCase.execute(url: url) else {
            errorMessage = "Only .xlsx or .csv files allowed."
            return
        }

        guard let size =
            try? url.resourceValues(
                forKeys: [.fileSizeKey]
            ).fileSize
        else { return }

        guard checkFileSizeUseCase.execute(size: Int64(size)) else {
            errorMessage = "File exceeds the 100 MB limit."
            return
        }

        let mb = Double(size) / (1024 * 1024)

        fileSize = String(
            format: "%.0f MB",
            mb < 1 ? 1 : mb
        )

        selectedFileName = url.lastPathComponent

        errorMessage = nil

        startUpload()
    }

    func startUpload() {

        isUploading = true
        isUploadComplete = false
        uploadProgress = 0.0

        timer = Timer.scheduledTimer(
            withTimeInterval: 0.05,
            repeats: true
        ) { timer in

            if self.uploadProgress < 1.0 {

                self.uploadProgress += 0.02

            } else {

                timer.invalidate()

                self.isUploading = false
                self.isUploadComplete = true
            }
        }
    }

    func cancelUpload() {

        timer?.invalidate()

        isUploading = false
        isUploadComplete = false

        uploadProgress = 0.0
        selectedFileName = nil
    }

    func resetFile() {

        isUploadComplete = false
        selectedFileName = nil
        uploadProgress = 0.0
    }
}

