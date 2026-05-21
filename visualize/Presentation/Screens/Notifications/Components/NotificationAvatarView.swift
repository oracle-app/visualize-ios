//
//  NotificationAvatarView.swift
//  visualize
//
//  Created by Miguel Degollado on 20/05/26.
//

import SwiftUI

struct NotificationAvatarView: View {
    let initials: String
    let color: Color
    let size: CGFloat
    var avatarURL: String? = nil

    var body: some View {
        ZStack {
            if let urlString = avatarURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else { initialsView }
                }
            } else { initialsView }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initialsView: some View {
        ZStack {
            Circle().fill(color)
            Text(initials)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}
