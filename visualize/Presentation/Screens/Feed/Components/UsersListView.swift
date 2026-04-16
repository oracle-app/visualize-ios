import SwiftUI

struct UsersListView: View {
    
    let users: [User]
    let onRemove: (User) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(users.indices, id: \.self) { index in
                    
                    UserRowView(
                        user: users[index],
                        onRemove: {
                            onRemove(users[index])
                        }
                    )
                    
                    if index != users.count - 1 {
                        Divider()
                            .padding(.leading, 8)
                    }
                }
            }
            .padding(.top, 16)
        }
    }
}
