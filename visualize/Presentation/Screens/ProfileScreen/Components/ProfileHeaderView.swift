//
//  ProfileHeaderView.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 27/04/26.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

// MARK: - Active Sheet

private enum ActiveSheet: Identifiable {
    case camera
    case editor

    var id: Int { hashValue }
}

// MARK: - Profile Header View

struct ProfileHeaderView: View {
    // MARK: - State properties

    @State private var isShowingPhotoOptions = false
    @State private var showDeleteAlert = false
    @State private var cameraImage: UIImage?
    @State private var activeSheet: ActiveSheet?

    // MARK: - Internal properties

    let onPickerRequested: () -> Void
    let onDelete: () -> Void
    let profilePictureURL: URL?
    let onUpload: (UIImage) -> Void
    let isUploading: Bool
    @Binding var pendingImage: UIImage?
    @Binding var showImageEditor: Bool

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            headerBackground

            profileAvatar
                .padding(.top, Metrics.avatarTopPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: Metrics.headerHeight, alignment: .top)
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(item: $activeSheet) { sheet in
            switch sheet {
            case .camera:
                CameraPickerView(image: $cameraImage)
                    .ignoresSafeArea()
            case .editor:
                EditProfilePhotoView(
                    image: pendingImage ?? UIImage(),
                    onCancel: {
                        activeSheet = nil
                        pendingImage = nil
                        showImageEditor = false
                    },
                    onSave: { image in
                        activeSheet = nil
                        pendingImage = nil
                        showImageEditor = false
                        onUpload(image)
                    }
                )
            }
        }
        .onChange(of: showImageEditor) { _, show in
            if show { activeSheet = .editor }
        }
        .onChange(of: cameraImage) { _, img in
            if let img {
                pendingImage = img
                activeSheet = .editor
            }
        }
    }

    // MARK: - Private properties

    private var headerBackground: some View {
        Image("AuthBackground")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: Metrics.backgroundHeight)
            .clipShape(ProfileHeaderShape())
            .clipped()
    }

    private var profileAvatar: some View {
        ZStack(alignment: .bottomTrailing) {
            // Avatar circle
            ZStack {
                if isUploading {
                    Color.appGray
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.5)
                } else if let url = profilePictureURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            avatarPlaceholder
                        case .empty:
                            Color.gray.opacity(0.2)
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

            // Edit button
            Button {
                isShowingPhotoOptions = true
            } label: {
                Image(systemName: "pencil")
            }
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
            .confirmationDialog(
                "Profile Photo",
                isPresented: $isShowingPhotoOptions
            ) {
                Button("Take photo") { activeSheet = .camera }
                Button("Choose from library") { onPickerRequested() }
                Button("Delete photo", role: .destructive) { showDeleteAlert = true }
            }
            .alert("Delete photo", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { onDelete() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone.")
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
    @Previewable @State var pending: UIImage?
    @Previewable @State var showEditor: Bool = false

    ProfileHeaderView(
        onPickerRequested: { },
        onDelete: { },
        profilePictureURL: nil,
        onUpload: { _ in },
        isUploading: false,
        pendingImage: $pending,
        showImageEditor: $showEditor
    )
}
