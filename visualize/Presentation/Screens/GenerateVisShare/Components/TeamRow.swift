//
//  TeamRow.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 11/04/26.
//
//
// A reusable row that displays team information.
// Includes selection state, team details, and avatar placeholders.
// Designed for use inside selectable lists.
//

import SwiftUI

struct TeamRow: View {
    
    let team: Team
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            
            ZStack {
                Circle()
                    .stroke(isSelected ? Color.appTeal : Color.gray.opacity(0.4), lineWidth: 2)
                    .frame(width: 24, height: 24)

                if isSelected {
                    Circle()
                        .fill(Color.appTeal)
                        .frame(width: 24, height: 24)

                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.body)
                    .foregroundColor(Color.primaryText)
                
                Text("^[\(team.members.count) member](inflect: true)")
                    .font(.system(size: 13))
                    .foregroundColor(Color.appTeal)
            }
            .padding(.leading, 6)
            
            Spacer()
            
            HStack(spacing: -20) {
                Circle()
                    .fill(Color.red.opacity(1))
                    .frame(width: 33, height: 33)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .zIndex(3)
                
                Circle()
                    .fill(Color.blue.opacity(1))
                    .frame(width: 33, height: 33)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .zIndex(2)
                
                Circle()
                    .fill(Color.green.opacity(1))
                    .frame(width: 33, height: 33)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .zIndex(1)
                
                ZStack {
                    Circle().fill(Color.white)
                    
                    Text("+2")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 68/255, green: 68/255, blue: 68/255))
                }
                .frame(width: 33, height: 33)
                .overlay(Circle().stroke(Color.appMint, lineWidth: 2))
                .padding(.leading, 10)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .listRowBackground(Color.white)
    }
}
