//
//  ShareSheet.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 11/04/26.
//
// Main screen that allows users to share content with teammates and teams.
// Integrates search functionality, selected users, and team selection in one view.
// Coordinates interactions between the ViewModel and reusable UI components


import SwiftUI

struct ShareSheet: View {
    
    @State var vm: ShareSheetViewModel
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(vm: ShareSheetViewModel = ShareSheetViewModel()) {
        _vm = State(initialValue: vm)
    }
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 32)
                .fill(.thinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                VStack(spacing: 16) {
                    
                    Spacer().frame(height: 1)
                    
                    Text("Personal feed")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(Color.appTeal)
                        .frame(maxWidth: 360)
                        .frame(height: 45)
                        .background(.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.appTeal, lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 4)
                    
                    
                    Text("Share with teammates")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(Color.primaryText)
                        .padding(.top, 15)
                    
                    EmailSearchField(
                        email: $vm.email,
                        onClear: { vm.clearEmail() },
                        isFocused: _isFocused
                    )
                    .frame(maxWidth: 360)
                    
                    
                    List {
                        
                        if !vm.users.isEmpty {
                            UsersListView(
                                users: vm.users,
                                onRemove: { vm.removeUser($0) }
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.top, -20)
                        }
                        
                        Section {
                            ForEach(vm.myTeams) { team in
                                TeamRow(
                                    team: team,
                                    isSelected: vm.isSelected(team),
                                    onTap: { vm.toggleSelection(team) }
                                )
                            }
                        } header: {
                            Text("My teams")
                                .foregroundStyle(Color.primaryText)
                        }
                        
                        Section {
                            ForEach(vm.joinedTeams) { team in
                                TeamRow(
                                    team: team,
                                    isSelected: vm.isSelected(team),
                                    onTap: { vm.toggleSelection(team) }
                                )
                            }
                        } header: {
                            Text("Teams I'm in")
                                .foregroundStyle(Color.primaryText)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .listSectionSpacing(8)
                    .padding(.top, -12)
                }
                
                .overlay(alignment: .top) {
                    if isFocused && !vm.filteredUsers.isEmpty {
                        SearchResultsDropdown(
                            results: vm.filteredUsers,
                            onSelect: { vm.addUser($0)}
                        )
                        .frame(maxWidth: 360)
                        .padding(.top, 200)
                        .shadow(radius: 10)
                        .zIndex(10)
                    }
                }
            }
            .task { vm.loadData() }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm", systemImage: "paperplane") { }
                        .tint(Color.primaryOrange)
                }
            }
        }
    }
    
    #Preview {
        NavigationStack {
            ShareSheet()
        }
    }
}
