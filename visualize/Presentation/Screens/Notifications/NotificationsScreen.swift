//
//  NotificationScreen.swift
//  visualize
//
//  Created by Miguel Degollado o

import SwiftUI

@MainActor
struct NotificationsScreen: View {

    @Environment(AppCoordinator.self) private var coordinator
    @StateObject private var viewModel: NotificationsViewModel
    private let skipLoad: Bool

    init(viewModel: NotificationsViewModel? = nil, skipLoad: Bool = false) {
        _viewModel = StateObject(wrappedValue: viewModel ?? NotificationsViewModel())
        self.skipLoad = skipLoad
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                contentView
            }
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .background(Color.appBackground)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .notificationsNavigationBarStyle()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { coordinator.pop() } label: {
                    Image(systemName: "bell.fill").foregroundStyle(Color.appNavy)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                if hasUnread {
                    Button("Mark all") { viewModel.markAllAsRead() }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTeal)
                }
            }
        }
        .onAppear {
            NotificationCenter.default.post(name: .notificationsScreenDidAppear, object: nil)
            guard !skipLoad else { return }
            viewModel.loadNotifications()
        }
        .onDisappear {
            NotificationCenter.default.post(name: .notificationsScreenDidDisappear, object: nil)
        }
    }

    private var hasUnread: Bool {
        guard case .loaded(let groups) = viewModel.state else { return false }
        return groups.flatMap(\.items).contains { !$0.isRead }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .loading:
            ProgressView().frame(maxWidth: .infinity).padding(.top, 100)

        case .loaded(let groups):
            loadedView(groups: groups)

        case .empty:
            NotificationsEmptyView()
                .frame(maxWidth: .infinity)
                .padding(.top, UIScreen.main.bounds.height * 0.22)

        case .error(let message):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40)).foregroundStyle(Color.appTeal)
                Text(message).font(.system(size: 16))
                    .foregroundStyle(Color.appSubtitle).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity).padding(.horizontal, 32).padding(.top, 100)
        }
    }

    private func loadedView(groups: [NotificationDisplayGroup]) -> some View {
        VStack(alignment: .leading, spacing: 28) {
            ForEach(groups) { group in
                if !group.items.isEmpty || group.id == "Today" {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(group.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.appNavy)
                            .padding(.horizontal, 24)

                        if group.items.isEmpty {
                            Text("No notifications yet.")
                                .font(.system(size: 16)).foregroundStyle(Color.appSubtitle)
                                .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 20)
                        } else {
                            NotificationGroupCard(
                                group: group,
                                onTap: { id in viewModel.markAsRead(id: id) },
                                onDelete: { id in viewModel.delete(id: id) }
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                }
            }

            if case .loaded(let groups) = viewModel.state, groups.flatMap(\.items).count > 0 {
                Text("No more notifications.")
                    .font(.system(size: 15, weight: .medium)).foregroundStyle(Color.appSubtitle)
                    .frame(maxWidth: .infinity, alignment: .center).padding(.top, 12)
            }
        }
    }
}

// MARK: - Preview wrapper

@MainActor
private struct PreviewWrapper: View {
    let state: NotificationsViewModel.NotificationsState
    var body: some View {
        let vm = NotificationsViewModel()
        let _ = vm.forceState(state)
        NavigationStack {
            NotificationsScreen(viewModel: vm, skipLoad: true)
                .environment(AppCoordinator())
        }
    }
}

#Preview("① Loaded") {
    PreviewWrapper(state: .loaded([
        NotificationDisplayGroup(id: "Today", items: [
            NotificationDisplayItem(id: "n1", boldPrefix: "Jocelyn Duarte ", message: "replied to your thread on \u{201C}Monthly Revenue\u{201D}", timestamp: "now", isRead: false, avatarInitials: "JD", avatarColor: Color(red: 0.40, green: 0.62, blue: 0.95)),
            NotificationDisplayItem(id: "n2", boldPrefix: "Eduardo Salazar ", message: "added you to the team \u{201C}Data Analytics\u{201D}.", timestamp: "20 min ago", isRead: false, avatarInitials: "ES", avatarColor: Color(red: 0.95, green: 0.58, blue: 0.40)),
            NotificationDisplayItem(id: "n3", boldPrefix: "Lucy Martinez ", message: "shared a new chart called \u{201C}Sales by Region\u{201D}.", timestamp: "1 hour ago", isRead: true, avatarInitials: "LM", avatarColor: Color(red: 0.40, green: 0.80, blue: 0.65))
        ]),
        NotificationDisplayGroup(id: "Yesterday", items: [
            NotificationDisplayItem(id: "n4", boldPrefix: "Jocelyn Duarte ", message: "replied to your thread on \u{201C}Monthly Revenue\u{201D}", timestamp: "1 day ago", isRead: true, avatarInitials: "JD", avatarColor: Color(red: 0.40, green: 0.62, blue: 0.95))
        ]),
        NotificationDisplayGroup(id: "Last 30 days", items: [
            NotificationDisplayItem(id: "n5", boldPrefix: "Lucy Martinez ", message: "shared a new chart.", timestamp: "Apr 4", isRead: true, avatarInitials: "LM", avatarColor: Color(red: 0.40, green: 0.80, blue: 0.65))
        ])
    ]))
}
#Preview("② Today empty") { PreviewWrapper(state: .loaded([NotificationDisplayGroup(id: "Today", items: []), NotificationDisplayGroup(id: "Yesterday", items: [NotificationDisplayItem(id: "p1", boldPrefix: "Jocelyn Duarte ", message: "replied to your thread.", timestamp: "1 day ago", isRead: false, avatarInitials: "JD", avatarColor: Color(red: 0.40, green: 0.62, blue: 0.95))])])) }
#Preview("③ Empty")   { PreviewWrapper(state: .empty) }
#Preview("④ Loading") { PreviewWrapper(state: .loading) }
#Preview("⑤ Error")   { PreviewWrapper(state: .error("No se pudieron cargar las notificaciones.")) }


