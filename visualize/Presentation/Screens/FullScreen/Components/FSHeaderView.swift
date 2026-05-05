//
//  FSHeaderView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 28/04/26.
//

import SwiftUI

struct FSHeaderView: View {
    let title: String
    let members: [AppUser]
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.primaryText)
                        .frame(width: 48, height: 48)
                        .glassEffect()
                }
                
                Spacer()
                
                    if !members.isEmpty {
                        HStack {
                            Text("Shared with:")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.white)
                        TeamAvatarsView(members: members, borderColor: Color.appMint, diameter: 29)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.appTeal.opacity(0.75))
        .background(.ultraThinMaterial.opacity(0.7))
    }
}

#Preview {
    FSHeaderView(
        title: "Relative performance of major currencies against the dollar",
        members: [
            AppUser(id: "1", email: "ana@mail.com", profilePictureURL: nil, username: "Ana"),
            AppUser(id: "2", email: "luis@mail.com", profilePictureURL: nil, username: "Luis"),
            AppUser(id: "3", email: "maria@mail.com", profilePictureURL: nil, username: "Maria"),
            AppUser(id: "4", email: "carlos@mail.com", profilePictureURL: nil, username: "Carlos"),
        ],
        onBack: {}
    )
}
