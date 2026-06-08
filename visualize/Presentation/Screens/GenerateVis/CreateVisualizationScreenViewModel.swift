//
//  CreateVisualizationScreenViewModel.swift
//  VisualizeApp
//
//  Created by Libia Fv on 14/04/26.
//
/// Description:
/// ViewModel responsible for managing the file upload logic for creating visualizations.
/// Validates that the file is of an allowed type (.xlsx or .csv) and does not exceed the defined size limit.
/// Manages the upload state, including progress, completion, and cancellation.
/// Calculates and formats the file size for display in the UI.
/// Uses use cases for file validation and size checking.
/// Controls the simulated upload progress using a timer.
/// Allows the upload process to be reset or cancelled based on user interaction.

import Foundation
import SwiftUI

@MainActor
@Observable
class CreateVisualizationScreenViewModel {
 
    var selectedFileName: String? = nil
    var errorMessage: String? = nil
 
    var isUploading: Bool = false
    var uploadProgress: Double = 0.0
    var isUploadComplete: Bool = false
    
    var fileSizeBytes: Int = 0
    var pickedFileURL: URL? = nil
    
    /// Formatted file size for display in the UI.
    /// Bytes are kept in `fileSizeBytes`; formatting happens only at the view boundary.
    var fileSize: String {
        let kb = Double(fileSizeBytes) / 1024
        let mb = kb / 1024

        if mb >= 1 {
            return "\(mb.formatted(.number.precision(.fractionLength(1)))) MB"
        } else {
            return "\(kb.formatted(.number.precision(.fractionLength(0)))) KB"
        }
    }
    private var timer: Timer?
 
    private let validateFileUseCase: ValidateFileUseCase
    private let checkFileSizeUseCase: CheckFileSizeUseCase

    init(
        validateFileUseCase: ValidateFileUseCase = ValidateFileUseCase(),
        checkFileSizeUseCase: CheckFileSizeUseCase = CheckFileSizeUseCase()
    ) {
        self.validateFileUseCase = validateFileUseCase
        self.checkFileSizeUseCase = checkFileSizeUseCase
    }

    func handleFile(url: URL) {

        guard validateFileUseCase.execute(url: url) else {
            errorMessage = String(localized: "Only .xlsx or .csv files allowed.")
            return
        }

        guard let size =
            try? url.resourceValues(
                forKeys: [.fileSizeKey]
            ).fileSize
        else { return }

        guard checkFileSizeUseCase.execute(size: Int64(size)) else {
            errorMessage = String(localized: "File exceeds the 100 MB limit.")
            return
        }
        
        // Copy to a stable temp location before security-scoped access ends.
        let dest = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(url.lastPathComponent)
        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: url, to: dest)
        } catch {
            errorMessage = String(localized: "Could not access the selected file.")
            return
        }

        fileSizeBytes = size
 
        selectedFileName = url.lastPathComponent
        pickedFileURL = dest
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
            if self.uploadProgress < 0.98 {
                self.uploadProgress += 0.02
            } else {
                // Pin to exactly 1.0 so the bar and text both show 100%.
                self.uploadProgress = 1.0
                timer.invalidate()
                Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    self.isUploading = false
                    self.isUploadComplete = true
                }
            }
        }
    }
 
    func cancelUpload() {
        timer?.invalidate()
        isUploading = false
        isUploadComplete = false
        uploadProgress = 0.0
        selectedFileName = nil
        removeTempFile()
        pickedFileURL = nil
    }
 
    func resetFile() {

        isUploadComplete = false
        isUploading = false
        selectedFileName = nil
        uploadProgress = 0.0
        fileSizeBytes = 0
        removeTempFile()
        pickedFileURL = nil
    }
    
    /// Deletes the temp copy of the file, if it exists.
    private func removeTempFile() {
        guard let url = pickedFileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
