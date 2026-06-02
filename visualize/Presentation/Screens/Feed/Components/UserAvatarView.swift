//
//  AvatarView.swift
//  visualize
//
//  Created by Carlos Amador on 28/04/26.
//

import SwiftUI

struct UserAvatarView: View {
    let user: AppUser
    var size: CGFloat = 33
    var showBorder: Bool = true
    
    var body: some View {
        ZStack {
            if let urlString = user.profilePictureURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .scaleEffect(0.5)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        fallbackAvatar
                    @unknown default:
                        fallbackAvatar
                    }
                }
            } else {
                fallbackAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Group {
                if showBorder {
                    Circle().stroke(Color.appMint, lineWidth: 2)
                }
            }
        )
    }
    
    private var fallbackAvatar: some View {
        ZStack {
            Color(UIColor.systemGray4)
            
            Text(String(user.username.prefix(1)).uppercased())
        
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

extension UserAvatarView {
    init(username: String, avatarURL: String?, size: CGFloat = 33, showBorder: Bool = false) {
        self.init(
            user: AppUser(
                id: "",
                email: "",
                profilePictureURL: avatarURL,
                username: username,
                role: .writer
            ),
            size: size,
            showBorder: showBorder
        )
    }
}
