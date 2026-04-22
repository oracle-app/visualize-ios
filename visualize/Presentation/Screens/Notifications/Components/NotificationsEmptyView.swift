//
//  NotificationsEmptyView.swift
//  visualize
//
//  Created by Miguel Degollado Ramirez on 22/04/26.


import SwiftUI

struct NotificationsEmptyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("notifications.empty.title", comment: ""))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.appTeal)

            Text(NSLocalizedString("notifications.empty.subtitle", comment: ""))
                .font(.system(size: 17))
                .foregroundStyle(Color.appSubtitle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview

#Preview {
    NotificationsEmptyView()
        .padding()
        .background(Color.appBackground)
}
