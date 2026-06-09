//
//  NotificationsEmptyView.swift
//  visualize
//
//  Created by Miguel Degollado

import SwiftUI

struct NotificationsEmptyView: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("No notifications yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColors.Brand.teal)
                .multilineTextAlignment(.center)

            Text("We'll notify you when there's something new.")
                .font(.system(size: 17))
                .foregroundStyle(AppColors.Text.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}
