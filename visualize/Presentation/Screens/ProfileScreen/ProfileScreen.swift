//
//  ProfileScreenView.swift
//  visualize
//
//  Created by Zuleyca Guadalupe Balles Soto on 27/04/26.
//

import SwiftUI
import _PhotosUI_SwiftUI
import AVFoundation

struct ProfileScreen: View {
    // MARK: - State properties

    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: ProfileScreenViewModel
    @AppStorage("selectedChartTheme") private var selectedThemeRaw: String = ChartColorTheme.lagoon.rawValue
    @State private var activeToast: Toast?
    @State private var toastTask: Task<Void, Never>?
    @State private var showLogoutAlert = false
    @State private var showPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var pendingImage: UIImage?
    @State private var showImageEditor = false
    @State private var isCameraActive = false

    // MARK: - Initialization

    init(
        logoutUseCase: LogoutUseCase,
        getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase,
        uploadProfilePhotoUseCase: UploadProfilePhotoUseCase,
        deleteProfilePhotoUseCase: DeleteProfilePhotoUseCase
    ) {
        _viewModel = State(initialValue: ProfileScreenViewModel(
            logoutUseCase: logoutUseCase,
            getCurrentUserProfileUseCase: getCurrentUserProfileUseCase,
            uploadProfilePhotoUseCase: uploadProfilePhotoUseCase,
            deleteProfilePhotoUseCase: deleteProfilePhotoUseCase
        ))
    }

    // MARK: - Private

    private var selectedTheme: ChartColorTheme {
        ChartColorTheme(rawValue: selectedThemeRaw) ?? .lagoon
    }

    /// Shows a toast and schedules its automatic dismissal, cancelling any
    /// previously scheduled dismissal so rapid changes don't leave it stuck.
    private func showToast(_ toast: Toast) {
        toastTask?.cancel()
        activeToast = toast
        toastTask = Task {
            try? await Task.sleep(for: .seconds(Metrics.toastDuration))
            guard !Task.isCancelled else { return }
            activeToast = nil
        }
    }
    
    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: Metrics.sectionSpacing) {
                ProfileHeaderView(
                    onPickerRequested: { showPhotoPicker = true },
                    onDelete: { viewModel.deleteProfileImage() },
                    profilePictureURL: viewModel.profilePictureURL,
                    onUpload: { image in viewModel.uploadProfileImage(image: image) },
                    isUploading: viewModel.isUploadingPhoto,
                    username: viewModel.username,
                    pendingImage: $pendingImage,
                    showImageEditor: $showImageEditor,
                    isCameraActive: $isCameraActive
                )
                VStack(spacing: Metrics.contentSpacing) {
                    ProfileUserInfoView(
                        username: viewModel.username,
                        email: viewModel.email
                    )
                    Divider()
                        .background(AppColors.Text.secondary.opacity(Metrics.dividerOpacity))
                    ProfilePreferencesSectionView(
                        availableThemes: ChartColorTheme.allCases,
                        selectedTheme: selectedTheme
                    ) { theme in
                        selectedThemeRaw = theme.rawValue
                        activeToast = Toast(
                            message: String(localized: "\(theme.title) theme applied", comment: "Theme name followed by 'theme applied'"),
                            type: .success
                        )
                        Divider()
                            .background(AppColors.Text.secondary.opacity(Metrics.dividerOpacity))
                        ProfilePreferencesSectionView(
                            availableThemes: ChartColorTheme.allCases,
                            selectedTheme: selectedTheme
                        ) { theme in
                            selectedThemeRaw = theme.rawValue
                            showToast(Toast(
                                message: String(localized: "\(theme.title) theme applied", comment: "Theme name followed by 'theme applied'"),
                                type: .success
                            ))
                        }
                        Divider()
                            .background(AppColors.Text.secondary.opacity(Metrics.dividerOpacity))
                        ProfileAboutSectionView(items: viewModel.aboutItems)
                        Button {
                            showLogoutAlert = true
                        } label: {
                            Text("Log out")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(AppColors.Status.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Metrics.buttonVerticalPadding)
                                .background {
                                    Capsule()
                                        .fill(Color.appBackground)
                                        .shadow(color: .black.opacity(Metrics.shadowOpacity), radius: Metrics.shadowRadius, x: 0, y: Metrics.shadowY)
                                }
                                .overlay {
                                    Capsule()
                                        .strokeBorder(AppColors.Status.red, lineWidth: Metrics.borderWidth)
                                }
                                .contentShape(Capsule())
                        }
                        .alert("Log out", isPresented: $showLogoutAlert) {
                            Button("Log out", role: .destructive, action: viewModel.logOut)
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("Are you sure you want to log out?")
                        }
                    }
                    Divider()
                        .background(Color.appSubtitle.opacity(Metrics.dividerOpacity))
                    ProfileAboutSectionView(items: viewModel.aboutItems)
                    Button("Log out", action: viewModel.logOut)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Metrics.buttonVerticalPadding)
                        .background {
                            Capsule()
                                .fill(Color.appBackground)
                                .shadow(color: .black.opacity(Metrics.shadowOpacity), radius: Metrics.shadowRadius, x: 0, y: Metrics.shadowY)
                        }
                        .overlay {
                            Capsule()
                                .strokeBorder(.red, lineWidth: Metrics.borderWidth)
                        }
                }
                .padding(.horizontal, Metrics.horizontalPadding)
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            Color.clear
                .photosPicker(
                    isPresented: $showPhotoPicker,
                    selection: $selectedItem,
                    matching: .images
                )
                .onChange(of: selectedItem) { _, newItem in
                    guard let newItem else { return }
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                pendingImage = uiImage
                                selectedItem = nil
                                showImageEditor = true
                            }
                        } else {
                            await MainActor.run {
                                selectedItem = nil
                                showToast(Toast(
                                    message: String(localized: "Could not load the selected photo"),
                                    type: .error
                                ))
                            }
                        }
                    }
                }
        }
        .appBackground()
        .onAppear {
            viewModel.loadProfile()
        }
        .portraitOrientationLock(!isCameraActive)
        .onChange(of: viewModel.isLoggedOut) { _, loggedOut in
            if loggedOut {
                coordinator.logout()
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = activeToast {
                ToastView(toast: toast)
                    .padding(.bottom, Metrics.toastBottomPadding)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.4), value: activeToast)
    }
}

// MARK: - Metrics

private enum Metrics {
    static let sectionSpacing: CGFloat = 14
    static let contentSpacing: CGFloat = 30
    static let horizontalPadding: CGFloat = 32
    static let buttonVerticalPadding: CGFloat = 10
    static let borderWidth: CGFloat = 1
    static let dividerOpacity: CGFloat = 0.2
    static let shadowOpacity: CGFloat = 0.25
    static let shadowRadius: CGFloat = 5
    static let shadowY: CGFloat = 2
    static let toastBottomPadding: CGFloat = 24
    static let toastDuration: TimeInterval = 3
}

#Preview {
    let authRepo = AuthRepositoryImpl(source: AuthFirebaseDatasource())
    let userRepo = UserRepositoryImpl(userDatasource: UserDatasource())

    ProfileScreen(
        logoutUseCase: LogoutUseCase(repository: authRepo),
        getCurrentUserProfileUseCase: GetCurrentUserProfileUseCase(
            authRepository: authRepo,
            userRepository: userRepo
        ),
        uploadProfilePhotoUseCase: UploadProfilePhotoUseCase(
            authRepository: authRepo,
            userRepository: userRepo
        ),
        deleteProfilePhotoUseCase: DeleteProfilePhotoUseCase(
            authRepository: authRepo,
            userRepository: userRepo
        )
    )
    .environment(AppCoordinator())
}
