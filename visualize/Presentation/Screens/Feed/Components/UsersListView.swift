//
//  UsersListView.swift
//  Visualize
//
//  Created by Diana Escalante on 14/04/26.
//

//
// A scrollable list view that displays multiple users.
// Each user is rendered using UserRowView and supports removal actions.
// Includes separators between items for better visual organization.
//

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
