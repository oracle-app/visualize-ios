//
//  UploadDropZone.swift
//  Visualize
//
//  Created by Libia Fv on 14/04/26.
//
// Description:
// View that represents a file upload drop zone for datasets.
// Displays an interactive area with a dashed border indicating file selection capability.
// Indicates supported formats (.xlsx and .csv) for data upload.
// Includes information about constraints such as maximum file size and single-file uploads.
// Presents a descriptive icon to reinforce the upload action.
// Serves as the main entry point for the data import workflow.

import SwiftUI

struct UploadDropZone: View {

    var body: some View {

        ZStack {

            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    style: StrokeStyle(
                        lineWidth: 1.5,
                        dash: [6, 4]
                    )
                )
                .foregroundColor(Color(.systemGray3))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                )

            VStack(spacing: 6) {

                Image(systemName: "document.badge.arrow.up")
                    .font(.system(size: 48))
                    .foregroundColor(
                        Color.appTeal
                    )
                    .padding(.bottom, 4)

                HStack(spacing: 0) {
                    Text("Choose a ")
                    Text(".xlsx").fontWeight(.semibold)
                    Text(" or ")
                    Text(".csv").fontWeight(.semibold)
                    Text(" file.")
                }
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

                VStack(spacing: 2) {
                    Text("Maximum file size: 100 MB")
                    Text("Only one dataset can be uploaded.")
                }
                .font(.system(size: 13))
                .foregroundColor(
                    Color.appTeal
                )
            }
            .padding(.vertical, 36)
            .padding(.horizontal, 20)
        }
    }
}


