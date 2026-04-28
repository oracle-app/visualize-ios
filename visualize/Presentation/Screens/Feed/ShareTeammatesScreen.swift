//
//  ShareTeammatesScreen.swift
//  Visualize
//
//  Created by Diana Escalante on 13/04/26.
//

//
/// Main screen that allows users to share content with teammates.
/// It handles UI states (loading, error, loaded), integrates search functionality,
/// and displays both suggested users and selected teammates.
/// Coordinates interactions between the ViewModel and reusable UI components.
//

import SwiftUI

struct ShareTeammatesScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    
    @State private var vm: ShareTeammatesViewModel
    
    init(viewModel: ShareTeammatesViewModel) {
        _vm = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            VStack(spacing: 16) {
                
                VStack(spacing: 5) {
                    Image(systemName: "person.2")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.primaryText)
                    
                    Text("Share to more teammates")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.primaryText)
                }
                
                contentView
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            
            if isFocused && vm.email.count >= 3 {
                SearchResultsDropdown(
                    results: vm.suggestedUsers
                ) { user in
                    vm.addUser(user)
                }
                .padding(.top, 140)
                .frame(maxWidth: 360)
                .shadow(radius: 10)
                .zIndex(1000)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm", systemImage: "paperplane") {
                    vm.confirmShare()
                    dismiss()
                }
                .tint(Color.primaryOrange)
                .disabled(vm.selectedUsers.isEmpty)
            }
        }
    }
    
    
    @ViewBuilder
    private var contentView: some View {
        loadedView()
    }
    
    private func loadedView() -> some View {
        VStack(spacing: 16) {
            ZStack(alignment: .top) {
                
                EmailSearchField(
                    email: $vm.email,
                    onClear: { vm.clearEmail() },
                    isFocused: _isFocused
                )
                .frame(maxWidth: 360)
            }
            
        
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Sharing with")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.primaryText)
                
                if vm.isLoading && vm.selectedUsers.isEmpty {
                    
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    
                } else if vm.selectedUsers.isEmpty {
                    
                    Text("Search for teammates you'd like to share with")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSubtitle)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                    
                } else {
                    
                    UsersListView(
                        users: vm.selectedUsers,
                        onRemove: { vm.removeUser($0) }
                    )
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        ShareTeammatesScreen(viewModel: .preview)
    }
}
