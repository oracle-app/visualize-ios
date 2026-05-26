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
    @State private var editorID = UUID()
    
    // MARK: - Internal properties
    
    let onPickerRequested: () -> Void
    let onDelete: () -> Void
    let profilePictureURL: URL?
    let onUpload: (UIImage) -> Void
    let isUploading: Bool
    let username: String
    @Binding var pendingImage: UIImage?
    @Binding var showImageEditor: Bool
    @Binding var isCameraActive: Bool
    
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
                    .onAppear { isCameraActive = true }
                    .onDisappear { isCameraActive = false }
            case .editor:
                EditProfilePhotoView(
                    image: pendingImage ?? UIImage(),
                    onCancel: {
                        activeSheet = nil
                        pendingImage = nil
                        showImageEditor = false
                        cameraImage = nil
                    },
                    onSave: { image in
                        activeSheet = nil
                        pendingImage = nil
                        showImageEditor = false
                        cameraImage = nil
                        onUpload(image)
                    }
                )
                .id(editorID)
            }
        }
        .onChange(of: showImageEditor) { _, show in
            if show { activeSheet = .editor }
        }
        .onChange(of: cameraImage) { _, img in
            guard let img else { return }
            pendingImage = img
            editorID = UUID()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
    
    private var fallbackAvatar: some View {
        ZStack {
            Color.appGray
            Text(String(username.prefix(1)).uppercased())
                .font(.system(size: Metrics.avatarIconSize * 1, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
    
    private var profileAvatar: some View {
        ZStack(alignment: .bottomTrailing) {
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
                            fallbackAvatar
                        case .empty:
                            Color.gray.opacity(0.2)
                        @unknown default:
                            fallbackAvatar
                        }
                    }
                } else {
                    fallbackAvatar
                }
            }
            .frame(width: Metrics.avatarSize, height: Metrics.avatarSize)
            .background(Color.appGray)
            .clipShape(.circle)
            .overlay {
                Circle()
                    .strokeBorder(.white, lineWidth: Metrics.avatarBorderWidth)
            }

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
    @Previewable @State var isCameraActive: Bool = false

    ProfileHeaderView(
        onPickerRequested: { },
        onDelete: { },
        profilePictureURL: nil,
        onUpload: { _ in },
        isUploading: false,
        username: "Mariana",
        pendingImage: $pending,
        showImageEditor: $showEditor,
        isCameraActive: $isCameraActive
    )
}
