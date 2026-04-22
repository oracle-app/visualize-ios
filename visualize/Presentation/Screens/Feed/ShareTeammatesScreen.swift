//
//  ShareTeammatesScreen.swift
//  Visualize
//
//  Created by Diana Escalante on 13/04/26.
//
import SwiftUI

struct ShareTeammatesScreen: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var viewModel = ShareTeammatesViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
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
                
        }
        .padding(.horizontal, 16)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
                
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
                
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm", systemImage: "checkmark") {
                    
                }
                .tint(Color.primaryOrange)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
                
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
        case .error:
            Text("Something went wrong")
                
        case .loaded(let users, let selected):
            loadedView(users: users, selected: selected)
        }
    }
        
        
    private func loadedView(users: [User], selected: [User]) -> some View {
        VStack(spacing: 16) {
                
            ZStack(alignment: .top) {
                    
                EmailSearchField(
                    email: $viewModel.email,
                    onClear: { viewModel.clearEmail() },
                    isFocused: _isFocused
                )
                .zIndex(1)
                    
                if isFocused && !viewModel.filteredUsers.isEmpty {
                    SearchResultsDropdown(
                        results: viewModel.filteredUsers
                    ) { user in
                        viewModel.addUser(user)
                    }
                    .padding(.top, 60)
                    .zIndex(2)
                }
            }
                
            UsersListView(
                users: selected,
                onRemove: { user in
                    viewModel.removeUser(user)
                }
            )
        }
    }
}


#Preview {
    NavigationStack {
        ShareTeammatesScreen()
    }
}
