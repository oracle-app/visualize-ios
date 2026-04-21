//
//  FeedViewModel.swift
//  Visualize
//
//  Created by Jorge Flores on 13/04/26.
//

import SwiftUI

struct FeedView: View {

    enum FeedOption: String {
        case allFeed = "All Feed"
        case personalFeed = "Personal Feed"
        case sharedFeed = "Shared Feed"
    }

    @State var selectedFeed: FeedOption = .allFeed
    @State var viewModel: FeedViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerView()
            contentView()
        }
        .onAppear {
            viewModel.loadData()
        }
    }



    func headerView() -> some View {
        HStack(spacing: 10) {

            HStack() {
                Text(selectedFeed.rawValue)
                    .font(.title.bold())
                    .foregroundStyle(Color(red: 19/255, green: 33/255, blue: 44/255))
                Image(systemName: "control")
                    .font(.body.bold())
                    .foregroundColor(.black)
                    .rotationEffect(.degrees(180))
                    .padding(.trailing, 10)
                
                
            }
            .overlay {
                Menu {
                    Button("All Feed") {
                        selectedFeed = .allFeed
                    }

                    Button("Personal Feed") {
                        selectedFeed = .personalFeed
                    }

                    Button("Shared Feed") {
                        selectedFeed = .sharedFeed
                    }

                } label: {
                    Color.clear
                    
                }
                
                
            }
            
        }
        .hLeading()
        .padding(.top, 40)
        .padding(.leading, 40)
        .padding(.bottom, 10)
    }


    @ViewBuilder
    func contentView() -> some View {
        switch viewModel.state {

        case .loading:
            LoadingListView()
                .hCenter()

        case .empty:
            EmptyListView {
                viewModel.loadData()
            }
            .hCenter()

        case .error:
            ErrorListView {
                viewModel.loadData()
            }
            .hCenter()

        case .loaded(let cards):
            LoadedListView(cards: cards)
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


#Preview {
    FeedView(viewModel: .init())
}
