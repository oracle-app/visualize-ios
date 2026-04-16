import SwiftUI

struct ShareSheetView: View {
    @State private var showSheet = false
    
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
            ShareSheet()
                .presentationDetents([.medium, .large])
                .presentationBackground(.clear)
        }
    }
}
#Preview {
    ShareSheetView()
}
