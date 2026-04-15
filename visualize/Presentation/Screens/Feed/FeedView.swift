//
//  FeedView.swift
//  Visualize
//
//  Created by Jorge Flores on 11/04/26.
//
import SwiftUI


struct FeedView: View {
    
    
    enum FeedOption: String {
        case allFeed = "All Feed"
        case personalFeed = "Personal Feed"
        case sharedFeed = "Shared Feed"
        var id: Self { self }
    }
    
    
    
    
    @State var selectedFeed: FeedOption = .allFeed
    @StateObject var viewModel: FeedViewModel
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false){
            
            LazyVStack(spacing: 15, pinnedViews:[.sectionHeaders]) {
                
                Section {
                    contentView()
                        
                    
                } header: {
                    headerView()
                }
                
            }
        }
        .onAppear{
            viewModel.loadData()
        }
    }
    
    
    func headerView() -> some View {
        
        HStack(spacing:10) {
            
            Text(selectedFeed.rawValue).font(.title.bold())
            
            Menu (){
                Button("All Feed", action: {
                    selectedFeed = .allFeed
                })
                
                Button("Personal Feed", action: {
                    selectedFeed = .personalFeed
                })
                
                Button("Shared Feed", action: {
                    selectedFeed = .sharedFeed
                })
            } label: {
                Image(systemName: "control")
                    .font(Font.body.bold())
                    .foregroundColor(.black)
                    .rotationEffect(Angle(degrees: 180))
            }
        }
        .hLeading()
        .padding([.top], 40)
        .padding([.leading], 40)
        .padding([.bottom], 10)
        .background(Color.gray.opacity(0.0)) //debug
        
    }
    
    @ViewBuilder
    func contentView() -> some View {
        
        
        
        switch viewModel.state {
            case .loading:
                if let screen = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.screen {

                    LoadingListView()
                    .frame(minHeight: screen.bounds.height * 0.60)
                }
            
            case .loaded(let cards):
                LoadedListView(cards: cards)
                
            
            case .empty:
                if let screen = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.screen {

                    EmptyListView {
                        viewModel.loadData()
                    }
                    .frame(minHeight: screen.bounds.height * 0.70)
                }

            case .error:
                if let screen = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.screen {
                    
                    ErrorListView{
                        viewModel.loadData()
                    }
                    
                        .frame(minHeight: screen.bounds.height * 0.70)
                }
            
        }
    }
}
        

struct LoadedListView: View {
    
    let cards: [CardModel]
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(cards) { card in
                Text(card.title)
                
                Text(card.description)
            }.background(Color.blue.opacity(0.5))
                
        }
    }
}

struct EmptyListView: View {
    
    let retryAction: () -> Void
    
    var body : some View {
        
        VStack(spacing: 10) {
            Spacer()
            VStack(){
                
                Text("No Visualizations Yet")
                    .font(Font.body.bold())
                    .foregroundStyle(Color(red: 52/255, green: 121/255, blue: 124/255))
                  
                Text("Your visualizations will appear here once you create or receive them")
                    .padding([.leading, .trailing], 80).foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            
            Button("Try Again"){
                retryAction()
            }
            .buttonStyle(.bordered)
            .frame(width: 300, height: 50)
            .controlSize(.large)
            .background(Color(red: 52/255, green: 121/255, blue: 124/255))
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding(.bottom, 20)
            
            
            
        }
        .hCenter()
    }
    
}


struct ErrorListView: View {
    let retryAction: () -> Void
    
    var body : some View {
        
        VStack(spacing: 10) {
            Spacer()
            VStack(){
                
                Text("Error")
                    .font(Font.body.bold())
                    .foregroundStyle(Color(red: 52/255, green: 121/255, blue: 124/255))
                  
                Text("An error has happened")
                    .padding([.leading, .trailing], 80).foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            
            Button("Something Went Wrong"){
                retryAction()
            }
            .buttonStyle(.bordered)
            .frame(width: 300, height: 50)
            .controlSize(.large)
            .background(Color(red: 52/255, green: 121/255, blue: 124/255))
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding(.bottom, 20)
            
            
            
        }
        .hCenter()
    }

    
    
}

struct LoadingListView: View {
    
    
    
    var body : some View {
        
        VStack(spacing: 15) {
            ProgressView("Loading Visualizations...")
                .font(Font.body.bold())
                .foregroundStyle(Color(red: 52/255, green: 121/255, blue: 124/255))
            Text("Fetching the latest visualizations for you.")
                .foregroundStyle(Color.gray)
                .padding([.leading, .trailing], 80)
                .multilineTextAlignment(.center)
            
        }
        .hCenter()
    }
    
    
}



extension View {
    
    
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    func hCenter() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity,  alignment: .center)
    }

}

#Preview {
    FeedView(viewModel: .init())
}
    
    

