//
//  NotificationGroupCard.swift
//  visualize
//

import SwiftUI

struct NotificationGroupCardView: View {
    let group: NotificationDisplayGroup
    var onTap: ((String) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(group.items.enumerated()), id: \.element.id) { index, item in
                NotificationRowView(
                    item: item,
                    showSeparator: index < group.items.count - 1,
                    onTap: onTap
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(AppColors.Brand.mint)
        )
    }
}
