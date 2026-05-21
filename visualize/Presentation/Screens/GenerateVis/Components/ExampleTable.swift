//
//  ExampleTable.swift
//  Visualize
//
//  Created by Libia Fv on 12/04/26.
//
// Description:
// Example view that shows the required format for datasets.
// Explains how the user should structure the table before uploading.
// Displays a sample table with example columns and rows.
// Includes headers and mock data to illustrate the expected format.
// Provides recommendations on best practices (one row per record, avoid empty or merged cells).
// Serves as a visual guide within the file upload flow.

import SwiftUI

struct ExampleTable: View {
    let columns = ["Date", "Product", "Sales", "Region"]
    let rows: [[String]] = [
        ["Jan", "A", "120", "North"],
        ["Feb", "B", "95", "South"],
        ["Mar", "A", "150", "North"],
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Dataset format requirements")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .padding(.bottom, 8)
                .padding(.top, 20)

            Text("Upload a table-formatted dataset with column headers in the first row.")
                .font(.system(size: 15))
                .foregroundColor(Color.appSubtitle)
                .lineSpacing(3)
                .padding(.bottom, 14)

            Text("Example")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.appTeal)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(columns, id: \.self) { col in
                        Text(col)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                    }
                }
                .background(Color(red: 121/255, green: 139/255, blue: 138/255).opacity(0.2))

                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)

                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    HStack(spacing: 0) {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                            Text(cell)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 9)
                                .padding(.horizontal, 10)
                        }
                    }
                    .background(Color(red: 121/255, green: 139/255, blue: 138/255).opacity(0.2))

                    if index < rows.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                    }
                }
            }
            .background(Color(.systemBackground).opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 3) {
                Text("Each row should represent a single data entry.")
                Text("Avoid empty rows or merged cells.")
            }
            .font(.system(size: 15))
            .foregroundColor(Color.appSubtitle)
            .padding(.top, 14)
        }
        .background(Color(.systemBackground))
    }
}





