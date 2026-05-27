//
//  SearchResultsDropdown.swift
//  Visualize
//
//  Created by Diana Escalante on 14/04/26.
//

//
/// A dropdown view that displays a list of user search results.
/// Each result is tappable and triggers a selection callback.
/// Uses UserRowView to render each user in a clean, compact list.
//

import SwiftUI

struct SearchResultsDropdown: View {
    
    let results: [AppUser]
    let onSelect: (AppUser) -> Void
    
    var body: some View {
        VStack {
            
            if results.isEmpty {
                Text(String(localized: "No results found"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
                
            } else {
                ForEach(results) { user in
                    
                    Button {
                        onSelect(user)
                    } label: {
                        UserRowView(user: user)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
    }
}
