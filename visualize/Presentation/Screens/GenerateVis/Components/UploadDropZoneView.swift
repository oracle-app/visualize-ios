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

struct UploadDropZoneView: View {

    var body: some View {

        ZStack {

            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    style: StrokeStyle(
                        lineWidth: 1.5,
                        dash: [6, 4]
                    )
                )
                .foregroundStyle(Color(.systemGray3))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                )

            VStack(spacing: 6) {

                Image(systemName: "document.badge.arrow.up")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        AppColors.Brand.teal
                    )
                    .padding(.bottom, 4)

                HStack(spacing: 0) {
                    Text("Choose a ", comment: "from Choose a .xlsx or .csv file.")
                    Text(".xlsx", comment: "from Choose a .xlsx or .csv file.").fontWeight(.semibold)
                    Text(" or ", comment: "from Choose a .xlsx or .csv file.")
                    Text(".csv", comment: "from Choose a .xlsx or .csv file.").fontWeight(.semibold)
                    Text(" file.", comment: "from Choose a .xlsx or .csv file.")
                }
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

                VStack(spacing: 2) {
                    Text(String(localized: "Maximum file size: 100 MB"))
                    Text(String(localized: "Only one dataset can be uploaded."))
                }
                .font(.system(size: 13))
                .foregroundStyle(
                    AppColors.Brand.teal
                )
            }
            .padding(.vertical, 36)
            .padding(.horizontal, 20)
        }
    }
}


