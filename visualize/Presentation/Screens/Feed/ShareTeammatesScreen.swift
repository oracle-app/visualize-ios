//
//  ShareTeammatesScreen.swift
//  Visualize
//
//  Created by Diana Escalante on 13/04/26.
//
import SwiftUI

struct User: Identifiable {
    let id = UUID()
    let name: String
    let email: String
}

struct ShareTeammatesScreen: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ShareTeammatesViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "person.2")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.primaryText)
            
            Text("Share to more teammates")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.primaryText)
        }
        
        VStack(spacing: 16) {
            
            ZStack(alignment: .top) {
                
                EmailSearchField(
                    email: $viewModel.email,
                    onClear: {
                        viewModel.clearEmail()
                    },
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
                users: viewModel.users,
                onRemove: { user in
                    viewModel.removeUser(user)
                }
            )
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
    }
}
