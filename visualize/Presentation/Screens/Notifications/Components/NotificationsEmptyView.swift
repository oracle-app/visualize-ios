//
//  NotificationsEmptyView.swift
//  visualize
//
//  Created by Miguel Degollado

import SwiftUI

struct NotificationsEmptyView: View {
    var body: some View {
        VStack(spacing: 6) {
            Text(NSLocalizedString("notifications.empty.title", comment: ""))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.appTeal)
                .multilineTextAlignment(.center)

            Text(NSLocalizedString("notifications.empty.subtitle", comment: ""))
                .font(.system(size: 17))
                .foregroundStyle(Color.appSubtitle)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}
