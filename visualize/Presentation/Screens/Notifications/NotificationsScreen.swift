//
//  NotificationsScreen.swift
//  visualize
//


import SwiftUI

@MainActor
struct NotificationsScreen: View {

    var viewModel: NotificationsScreenViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                contentView
            }
            .padding(.bottom, 100)
        }
        .background(Color.appBackground)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
        .tint(Color.appNavy)
        .onAppear {
            NotificationCenter.default.post(name: .notificationsScreenDidAppear, object: nil)
            viewModel.loadNotifications()
        }
        .onDisappear {
            NotificationCenter.default.post(name: .notificationsScreenDidDisappear, object: nil)
            viewModel.markAllAsRead()
        }
        .refreshable {
            viewModel.loadNotifications()
        }
    }

    // MARK: - Content state switcher

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 100)

        case .loaded(let groups):
            loadedView(groups: groups)

        case .empty:
            NotificationsEmptyView()
                .frame(maxWidth: .infinity)
                .padding(.top, UIScreen.main.bounds.height * 0.22)

        case .error(let message):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.appTeal)
                Text(message)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appSubtitle)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .padding(.top, 100)
        }
    }

    // MARK: - Loaded view

    private func loadedView(groups: [NotificationDisplayGroup]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(groups) { group in
                
                if !group.items.isEmpty || group.id == "Today" || group.id == "Yesterday" {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(group.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.appNavy)
                            .padding(.horizontal, 24)

                        if group.items.isEmpty {
                            Text("No notifications yet.")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.appSubtitle)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, 8)
                        } else {
                            NotificationGroupCardView(
                                group: group,
                                onTap: { id in viewModel.markAsRead(id: id) }
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                }
            }
            if case .loaded(let groups) = viewModel.state,
               groups.flatMap(\.items).count > 0 {
                Text("No more notifications.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.appSubtitle)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
        }
    }
}
