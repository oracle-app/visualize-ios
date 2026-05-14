//
//  ProfileHeaderView.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 27/04/26.
//

import SwiftUI

struct ProfileHeaderView: View {
    // MARK: - Internal properties

    let profilePictureURL: URL?
    let editProfilePhotoAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            headerBackground

            profileAvatar
                .padding(.top, Metrics.avatarTopPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: Metrics.headerHeight, alignment: .top)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Private properties

    private var headerBackground: some View {
        Image("SignUpBackground")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: Metrics.backgroundHeight)
            .clipShape(ProfileHeaderShape())
            .clipped()
    }

    private var profileAvatar: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let url = profilePictureURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            avatarPlaceholder
                        case .empty:
                            ProgressView()
                        @unknown default:
                            avatarPlaceholder
                        }
                    }
                } else {
                    avatarPlaceholder
                }
            }
            .frame(width: Metrics.avatarSize, height: Metrics.avatarSize)
            .background(Color.appGray)
            .clipShape(.circle)
            .overlay {
                Circle()
                    .strokeBorder(.white, lineWidth: Metrics.avatarBorderWidth)
            }

            Button("Edit profile photo", systemImage: "pencil", action: editProfilePhotoAction)
                .labelStyle(.iconOnly)
                .bold()
                .foregroundStyle(.white)
                .frame(width: Metrics.editButtonSize, height: Metrics.editButtonSize)
                .background(Color.appTeal)
                .clipShape(.circle)
                .overlay {
                    Circle()
                        .strokeBorder(.white, lineWidth: Metrics.editButtonBorderWidth)
                }
        }
    }

    private var avatarPlaceholder: some View {
        Image(systemName: "person.fill")
            .font(.system(size: Metrics.avatarIconSize, weight: .semibold))
            .foregroundStyle(Color.appSubtitle)
    }
}

// MARK: - ProfileHeaderShape

private struct ProfileHeaderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let curveStartY = rect.height * 0.68
        let curveControlY = rect.height * 1.08

        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: curveStartY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: curveStartY),
            control: CGPoint(x: rect.midX, y: curveControlY)
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Metrics

private enum Metrics {
    static let backgroundHeight: CGFloat = 220
    static let avatarSize: CGFloat = 175
    static let avatarIconSize: CGFloat = 57
    static let avatarOverlap: CGFloat = 92

    static var avatarTopPadding: CGFloat {
        backgroundHeight - avatarOverlap
    }

    static var headerHeight: CGFloat {
        avatarTopPadding + avatarSize
    }

    static let avatarBorderWidth: CGFloat = 2
    static let editButtonSize: CGFloat = 44
    static let editButtonBorderWidth: CGFloat = 2
}

#Preview {
    ProfileHeaderView(profilePictureURL: nil) {}
}
