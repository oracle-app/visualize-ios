//
//  CompletedFileCard.swift
//  Visualize
//
//  Created by Libia Fv on 14/04/26.
//

import SwiftUI

struct CompletedFileCard: View {
    let fileName: String
    let fileSize: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Image(systemName: "document.badge.arrow.up")
                    .foregroundColor(Color(red: 52/255, green: 121/255, blue: 124/255))
                    .font(.system(size: 28))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(fileName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text("\(fileSize) / \(fileSize)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.red)
                    .frame(width: 36, height: 36)
                    .glassEffect(.regular.tint(.red.opacity(0.1)).interactive(), in: Circle())
//                ZStack {
//                    Circle()
//                        .fill(Color.red.opacity(0.1))
//                        .frame(width: 36, height: 36)
//                    Image(systemName: "trash")
//                        .font(.system(size: 15))
//                        .foregroundColor(.red)
//                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(red: 52/255, green: 121/255, blue: 124/255).opacity(0.4), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
        )
        
    }
    
}
//#Preview {
//    CompletedFileCardView()
//}


