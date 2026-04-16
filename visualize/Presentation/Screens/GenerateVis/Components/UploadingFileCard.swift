//
//  UploadingFileCard.swift
//  Visualize
//
//  Created by Libia Fv on 14/04/26.
//

import SwiftUI

struct UploadingFileCard: View {

    let fileName: String
    let fileSize: String
    let progress: Double
    let onCancel: () -> Void

    var uploadedMB: String {

        let total =
            Double(
                fileSize.replacingOccurrences(
                    of: " MB",
                    with: ""
                )
            ) ?? 12

        let done = total * progress

        return String(
            format: "%.0f MB",
            done
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Image(systemName: "document.badge.arrow.up")
                    .foregroundColor(Color(red: 52/255, green: 121/255, blue: 124/255))
                    .font(.system(size: 28))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(fileName)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)

                Text("\(uploadedMB) / \(fileSize)")
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
//#Preview {
//    UploadingFileCardView()
//}


