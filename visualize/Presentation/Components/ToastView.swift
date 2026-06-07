//
//  ToastView.swift
//  visualize
//
//  Created by Diana Escalante on 07/05/26.
//

import SwiftUI

enum ToastType {
    case success
    case error

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .appTeal
        case .error: return .red
        }
    }
}

struct Toast: Equatable {
    let message: String
    let type: ToastType
}

/// A compact, floating notification overlay used to display transient feedback messages.
/// Automatically styled based on the success or error state with a customized glass effect.
struct ToastView: View {
    let toast: Toast

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.type.icon)
                .foregroundStyle(toast.type.color)
                .font(.body.weight(.semibold))
            Text(toast.message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular.tint(toast.type.color.opacity(0.08)), in: .capsule)
    }
}

// MARK: Preview
#Preview {
    VStack(spacing: 16) {
        ToastView(toast: Toast(message: "Visualization removed from your feed", type: .success))
        ToastView(toast: Toast(message: "Failed to delete visualization", type: .error))
    }
    .padding()
}
