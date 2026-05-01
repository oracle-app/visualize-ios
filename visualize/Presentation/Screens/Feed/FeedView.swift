//
//  FeedViewModel.swift
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


struct FeedView: View {
    
    
    // MARK: - States
    
    @State var selectedFeed: VisualizationFilter = .all
    @State var viewModel: FeedViewModel
    @State var isPrimaryActionVisible: Bool = true
    @State var title: String?
    @State var safeArea: EdgeInsets = .init()
    @State private var sharePayload: SharePayload?
    @State private var usersToShare: [AppUser] = []
    
    var shouldLoad: Bool = true
    
    // MARK: - Body
    var body: some View {
        
        NavigationStack{
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    headerView()
                    contentView()
                }
                .padding(0)
                
                
            }
            .customToolBar(isPrimaryActionVisible: isPrimaryActionVisible, title: title) {
            } trailing: {
                HStack(spacing: 15) {
                    Button("Notifications", systemImage: "bell") {
                        
                    }
                }
            } principal: {
                if let title {
                        Text(title)
                        .fontWeight(.semibold)
                        .transition(.offset(y: 10).combined(with: AnyTransition(.blurReplace)))
                    }

                        
            } primaryAction: {
                
            }
            .onAppear {
                if shouldLoad {
                    viewModel.loadData()
                }
            }
            .sheet(item: $sharePayload) { payload in
                let userDatasource = UserDatasource()
                let visualizationDatasource = VisualizationDatasource(userDatasource: userDatasource)
                let visualizationRepository = VisualizationRepositoryImpl(
                    userDatasource: userDatasource,
                    visualizationDatasource: visualizationDatasource
                )
                
                NavigationStack {
                    ShareTeammatesScreen(
                        viewModel: ShareTeammatesViewModel(
                            userRepository: UserRepositoryImpl(
                                userDatasource: userDatasource
                            ),
                            updateSharedUsersUseCase: UpdateSharedUsersUseCase(
                                visualizationRepository: visualizationRepository
                            ),
                            visualizationID: payload.visualizationID,
                            initialUsers: payload.users
                        ),
                        onConfirm: {
                            viewModel.loadData()
                        }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .coordinateSpace(name: "scroll")
        }
        
        

        .onGeometryChange(for: EdgeInsets.self) {
            $0.safeAreaInsets
        } action: { newValue in
            safeArea = newValue
        }
    }


    // MARK: - Header
    func headerView() -> some View {
        
        
        
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
                    .foregroundStyle(Color(red: 19/255, green: 33/255, blue: 44/255))
                    .onGeometryChange(for: Bool.self) {
                        let height = $0.size.height
                        let offset = $0.frame(in: .named("scroll")).minY
                        return -offset > height
                    } action: { newValue in
            
                        withAnimation(.smooth(duration: 0.10)) {
                                title = newValue ? selectedFeed.title : nil
                            }
                    }

                Image(systemName: "control")
                    .font(.body.bold())
                    .foregroundColor(.black)
                    .rotationEffect(.degrees(180))
                    .padding(.trailing, 10)
            }
            .hLeading()
            .padding(.leading, 35)
        }
        
        
    }
         
    
    // MARK: - Builder

    @ViewBuilder
    func contentView() -> some View {
        switch viewModel.state {

        case .loading:
            
            LoadingListView()
                
                

        case .empty:
            EmptyListView {
                viewModel.loadData()
            }
            

        case .error:
            ErrorListView {
                viewModel.loadData()
            }
            

        case .loaded(let items):
            LoadedListView(
                items: items,
                onShare: { visualizationID, users in
                    sharePayload = SharePayload(
                        visualizationID: visualizationID,
                        users: users
                    )
                }
            )
        }
    }
}


extension View {

    func hLeading() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
    }

    func hCenter() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}


struct SharePayload: Identifiable {
    let id = UUID()
    let visualizationID: String
    let users: [AppUser]
}

// MARK: - Preview

#Preview {
    FeedView(viewModel: .preview, shouldLoad: true)
}
