import SwiftUI

struct SearchResultsDropdown: View {
    
    let results: [User]
    let onSelect: (User) -> Void
    
    var body: some View {
        VStack() {
            ForEach(results) { user in
                
                Button {
                    onSelect(user)
                } label: {
                    UserRowView(user: user)
                }
                .buttonStyle(.plain)
                
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
    }
}
