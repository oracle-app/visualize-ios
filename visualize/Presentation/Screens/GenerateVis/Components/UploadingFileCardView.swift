//
//  UploadingFileCard.swift
//  Visualize
//
//  Created by Libia Fv on 14/04/26.
//
// Description:
// Card view that shows the upload status of a file in progress.
// Displays the file name, total file size, and current upload progress.
// Dynamically calculates the uploaded MB based on progress.
// Includes an animated progress bar that updates in real time.
// Allows the user to cancel the upload through an action button.
// Designed to provide clear feedback during the file upload process.

import SwiftUI

struct UploadingFileCardView: View {

    let fileName: String
    let fileSize: String
    let progress: Double
    let onCancel: () -> Void

    var uploadedSize: String {

        let totalBytes: Double
        if fileSize.contains("MB") {
            let value = Double(fileSize.replacingOccurrences(of: " MB", with: "")) ?? 0
            totalBytes = value * 1024 * 1024
        } else {
            let value = Double(fileSize.replacingOccurrences(of: " KB", with: "")) ?? 0
            totalBytes = value * 1024
        }

        let doneBytes = totalBytes * progress
        let doneKB = doneBytes / 1024
        let doneMB = doneKB / 1024

        if doneMB >= 1 {
            return String(format: "%.1f MB", doneMB)
        } else {
            return String(format: "%.0f KB", doneKB)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Image(systemName: "document.badge.arrow.up")
                    .foregroundColor(AppColors.Brand.teal)
                    .font(.system(size: 28))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(fileName)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)

                Text("\(uploadedSize) / \(fileSize)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 26/255, green: 177/255, blue: 127/255))
                        .frame(width: max(0, CGFloat(progress) * 200), height: 6)
                        .animation(.linear(duration: 0.1), value: progress)
                }
                .frame(maxWidth: .infinity)
            }

            Spacer()

            VStack(spacing: 4) {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 18)
                }
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }}




