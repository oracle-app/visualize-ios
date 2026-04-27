//
//  ShareSheetView.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 11/04/26.
//
// Entry view that presents the ShareSheet as a modal.
// Handles navigation context and sheet presentation.
//

import SwiftUI

struct ShareSheetView: View {
    @State private var showSheet = false
    private let userDatasource = UserDatasource()
    private let teamDatasource = TeamDatasource()
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                Text("Content")
                    .font(.title)
                    .foregroundColor(.black)
            }
            
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Share", systemImage: "square.and.arrow.up") {
                        showSheet.toggle()
                    }
                }
            }
        }
        
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                
                ShareSheet(viewModel: ShareSheetViewModel(teamRepository: TeamRepositoryImpl(teamDatasource: teamDatasource, userDatasource: userDatasource), userRepository: UserRepositoryImpl(userDatasource: userDatasource)))
            }
            .presentationDetents([.medium, .large])
            .presentationBackground(.clear)
        }
}
    
}
#Preview {
    ShareSheetView()
}
