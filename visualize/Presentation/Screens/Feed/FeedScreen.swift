//
//  FeedView.swift
//  Visualize
//
//  Created by Jorge Flores on 13/04/26.
//

///  This file defines the main FeedView of the application, responsible for displaying
///  a scrollable feed of content and managing its different UI states through a
///  FeedViewModel.
///
///  It supports multiple feed filters (All, Personal, Shared), dynamic header behavior,
///  and a custom toolbar configuration with primary and trailing actions. The view
///  reacts to changes in the ViewModel state to display loading, empty, error, or
///  loaded content accordingly.
///
///  It also manages UI interactions such as presenting a share sheet, updating the
///  navigation title based on scroll position, and adapting layout based on safe area
///  insets using geometry tracking.

import SwiftUI
import Foundation

struct FeedScreen: View {

    @Environment(AppCoordinator.self) private var coordinator

    // MARK: - States

    @State var selectedFeed: VisualizationFilter = .all
    @State var viewModel: FeedScreenViewModel
    @State var isPrimaryActionVisible: Bool = true
    @State var title: String?
    @State var safeArea: EdgeInsets = .init()
    @State private var sharePayload: SharePayload?
    @State private var usersToShare: [AppUser] = []
    @State private var selectedCard: VisualizationCard? = nil
    @State private var isScrolledPastHeader: Bool = false
    @State private var isScrollDisabled: Bool = false
    @State private var scrollPosition: ScrollPosition = .init(idType: String.self)
    @State private var searchPressed: Bool = false

    var shouldLoad: Bool = true

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Color.clear
                        .frame(height: 0)
                        .id("top")
                headerView()
                contentView()
            }
            .padding(0)
        }
        .navigationDestination(item: $selectedCard) { card in
            FullScreen(card: card)
                .navigationBarBackButtonHidden(true)
        }
        .customToolBar(isPrimaryActionVisible: isPrimaryActionVisible, title: title) {
            if viewModel.isSearchActive {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.body)
                    TextField(String(localized: "Search visualizations..."), text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .frame(width: 220)
                        .submitLabel(.search)
                    Button {
                        withAnimation(.smooth(duration: 0.2)) {
                            viewModel.isSearchActive = false
                            viewModel.clearSearch()
                            
                        }
                        Task {
                            try? await Task.sleep(for: .seconds(0.1))
                            guard !viewModel.isSearchActive else { return }
                            withAnimation {
                                title = isScrolledPastHeader ? selectedFeed.title : nil
                            }
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            } else {
                Button {
                    if isScrolledPastHeader {
                        searchPressed = true
                        isScrollDisabled = true
                        title = nil
                        withAnimation(.smooth(duration: 0.3)) {
                            scrollPosition.scrollTo(id: "top", anchor: .top)
                        }
                        isScrollDisabled = false

                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(0.25))
                            viewModel.isSearchActive = true
                            searchPressed = false
                        }
                    } else {
                        searchPressed = true
                        title = nil
                        withAnimation {
                            scrollPosition.scrollTo(id: "top", anchor: .top)
                        }
                        withAnimation {
                            viewModel.isSearchActive = true
                        }
                        searchPressed = false
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        } trailing: {
            HStack(spacing: 15) {
                Button {
                    coordinator.push(.notifications)
                } label: {
                    Image(systemName: "bell")
                        .overlay(alignment: .topTrailing){
                            if viewModel.hasUnreadNotifications {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }
                }
                .accessibilityLabel(String(localized: "Notifications"))
                .accessibilityValue(viewModel.hasUnreadNotifications ? String(localized: "Unread items") : "")
            }
        } principal: {
            if let title {
                Button {
                    isScrollDisabled = true
                    withAnimation(.smooth(duration: 0.3)) {
                        scrollPosition.scrollTo(id: "top", anchor: .top)
                    }
                    isScrollDisabled = false
                } label: {
                    Text(title)
                        .fontWeight(.semibold)
                }
                .transition(.offset(y: 10).combined(with: AnyTransition(.blurReplace)))
            }
        } primaryAction: {
        }
        .refreshable {
            try? await Task.sleep(for: .seconds(0.2))
            viewModel.loadData(forceRefresh: false)
            
        }
        .onAppear {
            if shouldLoad {
                viewModel.loadData()
            }
        }
        .task(id: viewModel.currentUserID) {
            await viewModel.listenForUnreadNotifications()
        }
        .portraitOrientationLock()
        .scrollDisabled(isScrollDisabled)
        .scrollPosition($scrollPosition)
        .sheet(item: $sharePayload) { payload in
            let userDatasource = UserDatasource()
            let teamsDatasource = TeamDatasource()
            let authDatasource = AuthFirebaseDatasource()
            let visualizationDatasource = VisualizationDatasource(
                userDatasource: userDatasource,
                teamsDatasource: teamsDatasource
            )
            let visualizationRepository = VisualizationRepositoryImpl(
                userDatasource: userDatasource,
                visualizationDatasource: visualizationDatasource,
                teamsDatasource: teamsDatasource
            )
            let teamRepository = TeamRepositoryImpl(
                teamDatasource: teamsDatasource,
                userDatasource: userDatasource
            )
            let authRepository = AuthRepositoryImpl(
                source: authDatasource
            )
            NavigationStack {
                ShareTeammatesScreen(
                    viewModel: ShareTeammatesScreenViewModel(
                        userRepository: UserRepositoryImpl(
                            userDatasource: userDatasource
                        ),
                        teamRepository: teamRepository,
                        authRepository: authRepository,
                        updateSharingUseCase: UpdateSharingUseCase(
                            visualizationRepository: visualizationRepository,
                            userRepository: UserRepositoryImpl(userDatasource: userDatasource)
                        ),
                        visualizationID: payload.visualizationID,
                        initialUsers: payload.editableUsers,
                        initialTeamIDs: payload.initialTeamIDs
                    ),
                    onConfirm: {
                        viewModel.loadData()
                        viewModel.showToast(Toast(message: String(localized: "Sharing updated successfully"),type: .success))
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .coordinateSpace(name: "scroll")
        .overlay(alignment: .bottom) {
            if let toast = viewModel.currentToast {
                ToastView(toast: toast)
                    .padding(.bottom, 74)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity.combined(with: .scale(scale: 0.95))
                        )
                    )
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: viewModel.currentToast)
        .onChange(of: coordinator.pendingToast) { _, toast in
            guard let toast else { return }
            viewModel.showToast(toast)
            viewModel.loadData(forceRefresh: true)
            coordinator.pendingToast = nil
        }
        .onGeometryChange(for: EdgeInsets.self) {
            $0.safeAreaInsets
        } action: { newValue in
            safeArea = newValue
        }
        .appBackground()
    }

    // MARK: - Header

    /// Builds the feed header with a menu to switch between All, Personal, and Shared filters.
    @ViewBuilder
    func headerView() -> some View {
        if !viewModel.isSearchActive && !searchPressed {
            Menu {
                Button {
                    selectedFeed = .all
                    viewModel.setVisualizationFilter(selectedFeed)
                } label: {
                    Label("All Feed", systemImage: selectedFeed == .all ? "checkmark" : "")
                }
                Button {
                    selectedFeed = .personal
                    viewModel.setVisualizationFilter(selectedFeed)
                } label: {
                    Label("Personal Feed", systemImage: selectedFeed == .personal ? "checkmark" : "")
                }
                Button {
                    selectedFeed = .shared
                    viewModel.setVisualizationFilter(selectedFeed)
                } label: {
                    Label("Shared Feed", systemImage: selectedFeed == .shared ? "checkmark" : "")
                }
            } label: {
                HStack(spacing: 10) {
                    Text(selectedFeed.title)
                        .font(.title.bold())
                        .foregroundStyle(AppColors.Text.primary)
                        .onGeometryChange(for: Bool.self) {
                            let height = $0.size.height
                            let offset = $0.frame(in: .named("scroll")).minY
                            return -offset > height
                        } action: { newValue in
                            isScrolledPastHeader = newValue
                            withAnimation(.smooth(duration: 0.10)) {
                                title = newValue ? selectedFeed.title : nil
                            }
                        }
                    Image(systemName: "control")
                        .font(.body.bold())
                        .foregroundStyle(AppColors.Text.primary)
                        .rotationEffect(.degrees(180))
                        .padding(.trailing, 10)
                }
                .hLeading()
                .padding(.leading, 35)
                .opacity(isScrolledPastHeader ? 0 : 1)
                .animation(.smooth(duration: 0.10), value: isScrolledPastHeader)
            }
        }
    }

    // MARK: - Content

    /// Builds the content area based on the current feed state, including search results.
    @ViewBuilder
    func contentView() -> some View {
        switch viewModel.state {
        case .loading:
            if !viewModel.isSearchActive { LoadingListView() }
        case .empty:
            if !viewModel.isSearchActive { EmptyListView { viewModel.loadData() } }
        case .error:
            if !viewModel.isSearchActive { ErrorListView { viewModel.loadData() } }
        case .loaded(let items):
            if viewModel.isSearchActive && viewModel.searchQuery.count >= 2 {
                if viewModel.searchResults.isEmpty {
                    VStack {
                        Text(String(localized: "No results for \"\(viewModel.searchQuery)\""))
                            .font(.body.bold())
                            .foregroundStyle(AppColors.Brand.teal)
                        Text(String(localized: "Try a different search term"))                            .foregroundStyle(.gray)
                    }
                    .hCenter()
                    .padding(.top, 300)
                } else {
                    LoadedListView(
                        items: viewModel.searchResults,
                        onShare: { visualizationID, allUsers, editableUsers, teamIDs in
                            sharePayload = SharePayload(
                                visualizationID: visualizationID,
                                allUsers: allUsers,
                                editableUsers: editableUsers,
                                initialTeamIDs: teamIDs
                            )
                        },
                        onTap: { card in selectedCard = card },
                        onHide: { visualizationID in viewModel.hideVisualization(visualizationID: visualizationID) },
                        onDelete: { visualizationID in viewModel.deleteVisualization(visualizationID: visualizationID) },
                        currentUserID: viewModel.currentUserID,
                        currentUserRole: viewModel.currentUserRole
                    )
                }
            } else {
                LoadedListView(
                    items: items,
                    onShare: { visualizationID, allUsers, editableUsers, teamIDs in
                        sharePayload = SharePayload(
                            visualizationID: visualizationID,
                            allUsers: allUsers,
                            editableUsers: editableUsers,
                            initialTeamIDs: teamIDs
                        )
                    },
                    onTap: { card in selectedCard = card },
                    onHide: { visualizationID in viewModel.hideVisualization(visualizationID: visualizationID) },
                    onDelete: { visualizationID in viewModel.deleteVisualization(visualizationID: visualizationID) },
                    currentUserID: viewModel.currentUserID,
                    currentUserRole: viewModel.currentUserRole
                )
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    func hLeading() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
    }

    func hCenter() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Models

struct SharePayload: Identifiable {
    let id = UUID()
    let visualizationID: String
    let allUsers: [AppUser]
    let editableUsers: [AppUser]
    let initialTeamIDs: [String]
}

// MARK: - Preview

#Preview {
    NavigationStack{
        FeedScreen(
            viewModel: .preview,
            shouldLoad: true
        )
        .environment(AppCoordinator())
    }
}
