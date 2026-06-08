//
//  CreateVisualizationScreenViewModelTests.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 07/06/26.
//
//  Unit tests for the Generate Visualization upload flow:
//  - GENV-001: Upload valid .xlsx file successfully
//  - GENV-002: Upload valid .csv file successfully
//  - GENV-003: Reject unsupported file type
//  - GENV-004: Reject file larger than 100 MB
//  - GENV-005: Cancel upload in progress
//  - GENV-006: Reset file after completed upload
//

import XCTest
@testable import visualize

@MainActor
final class CreateVisualizationScreenViewModelTests: XCTestCase {

    // MARK: - Helpers

    /// Creates a temporary file with the requested extension and size.
    /// - Parameters:
    ///   - fileName: File name including extension.
    ///   - sizeInBytes: Size to assign to the file.
    /// - Returns: Local file URL inside the temporary directory.
    private func makeTemporaryFile(fileName: String, sizeInBytes: UInt64 = 1_024) throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let url = directory.appendingPathComponent(fileName)
        FileManager.default.createFile(atPath: url.path, contents: Data())

        let handle = try FileHandle(forWritingTo: url)
        try handle.truncate(atOffset: sizeInBytes)
        try handle.close()

        return url
    }

    /// Waits until the simulated upload reaches completion or the timeout expires.
    /// - Parameters:
    ///   - sut: ViewModel under test.
    ///   - timeout: Maximum number of seconds to wait.
    private func waitForUploadCompletion(
        _ sut: CreateVisualizationScreenViewModel,
        timeout: TimeInterval = 10.0
    ) {
        let deadline = Date().addingTimeInterval(timeout)

        while !sut.isUploadComplete, Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        }
    }

    // MARK: - GENV-001 / GENV-002

    // GENV-001 — Valid .xlsx file starts and completes simulated upload.
    func test_handleFile_withValidXLSX_setsUploadComplete() throws {
        let sut = CreateVisualizationScreenViewModel()
        let fileURL = try makeTemporaryFile(fileName: "dataset.xlsx")

        sut.handleFile(url: fileURL)
        waitForUploadCompletion(sut)

        XCTAssertEqual(sut.selectedFileName, "dataset.xlsx")
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(sut.isUploadComplete, "Expected upload to complete before timeout.")
        XCTAssertFalse(sut.isUploading)
        XCTAssertEqual(sut.uploadProgress, 1.0, accuracy: 0.05)
        XCTAssertNotNil(sut.pickedFileURL)
    }

    // GENV-002 — Valid .csv file starts and completes simulated upload.
    func test_handleFile_withValidCSV_setsUploadComplete() throws {
        let sut = CreateVisualizationScreenViewModel()
        let fileURL = try makeTemporaryFile(fileName: "dataset.csv")

        sut.handleFile(url: fileURL)
        waitForUploadCompletion(sut)

        XCTAssertEqual(sut.selectedFileName, "dataset.csv")
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(sut.isUploadComplete, "Expected upload to complete before timeout.")
        XCTAssertFalse(sut.isUploading)
        XCTAssertEqual(sut.uploadProgress, 1.0, accuracy: 0.05)
        XCTAssertNotNil(sut.pickedFileURL)
    }

    // MARK: - GENV-003 / GENV-004

    // GENV-003 — Unsupported file extension is rejected.
    func test_handleFile_withUnsupportedFileType_setsValidationError() throws {
        let sut = CreateVisualizationScreenViewModel()
        let fileURL = try makeTemporaryFile(fileName: "dataset.txt")

        sut.handleFile(url: fileURL)

        XCTAssertEqual(sut.errorMessage, "Only .xlsx or .csv files allowed.")
        XCTAssertNil(sut.selectedFileName)
        XCTAssertFalse(sut.isUploading)
        XCTAssertFalse(sut.isUploadComplete)
        XCTAssertEqual(sut.uploadProgress, 0.0)
        XCTAssertNil(sut.pickedFileURL)
    }

    // GENV-004 — Files larger than 100 MB are rejected.
    func test_handleFile_withFileLargerThan100MB_setsSizeError() throws {
        let sut = CreateVisualizationScreenViewModel()
        let fileURL = try makeTemporaryFile(
            fileName: "large-dataset.csv",
            sizeInBytes: 101 * 1024 * 1024
        )

        sut.handleFile(url: fileURL)

        XCTAssertEqual(sut.errorMessage, "File exceeds the 100 MB limit.")
        XCTAssertNil(sut.selectedFileName)
        XCTAssertFalse(sut.isUploading)
        XCTAssertFalse(sut.isUploadComplete)
        XCTAssertEqual(sut.uploadProgress, 0.0)
        XCTAssertNil(sut.pickedFileURL)
    }

    // MARK: - GENV-005 / GENV-006

    // GENV-005 — Cancel upload resets state and removes the temporary file.
    func test_cancelUpload_resetsStateAndRemovesTempFile() throws {
        let sut = CreateVisualizationScreenViewModel()
        let fileURL = try makeTemporaryFile(fileName: "dataset.csv")

        sut.handleFile(url: fileURL)
        let copiedURL = try XCTUnwrap(sut.pickedFileURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: copiedURL.path))

        sut.cancelUpload()

        XCTAssertNil(sut.selectedFileName)
        XCTAssertNil(sut.pickedFileURL)
        XCTAssertFalse(sut.isUploading)
        XCTAssertFalse(sut.isUploadComplete)
        XCTAssertEqual(sut.uploadProgress, 0.0)
        XCTAssertFalse(FileManager.default.fileExists(atPath: copiedURL.path))
    }

    // GENV-006 — Reset after completed upload clears state and removes the temporary file.
    func test_resetFile_afterCompletedUpload_resetsStateAndRemovesTempFile() throws {
        let sut = CreateVisualizationScreenViewModel()
        let fileURL = try makeTemporaryFile(fileName: "dataset.xlsx")

        sut.handleFile(url: fileURL)
        waitForUploadCompletion(sut)

        let copiedURL = try XCTUnwrap(sut.pickedFileURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: copiedURL.path))
        XCTAssertTrue(sut.isUploadComplete)

        sut.resetFile()

        XCTAssertNil(sut.selectedFileName)
        XCTAssertNil(sut.pickedFileURL)
        XCTAssertFalse(sut.isUploading)
        XCTAssertFalse(sut.isUploadComplete)
        XCTAssertEqual(sut.uploadProgress, 0.0)
        XCTAssertEqual(sut.fileSize, "0 KB")
        XCTAssertFalse(FileManager.default.fileExists(atPath: copiedURL.path))
    }
}
