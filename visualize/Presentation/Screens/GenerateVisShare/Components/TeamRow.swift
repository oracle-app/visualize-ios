import SwiftUI

struct TeamRow: View {
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Data Analyst")
                    .font(.body)
                    .foregroundColor(Color.primaryText)
                
                Text("2 members")
                    .font(.system(size: 13))
                    .foregroundColor(Color.primaryAzul)
            }
            
            Spacer()
            
            HStack(spacing: -20) {
                            Circle()
                                .fill(Color.red.opacity(1))
                                .frame(width: 33, height: 33)
                                .overlay(Circle().stroke(Color.appMint, lineWidth: 2))
                                .zIndex(3)
                            
                            Circle()
                                .fill(Color.blue.opacity(1))
                                .frame(width: 33, height: 33)
                                .overlay(Circle().stroke(Color.appMint, lineWidth: 2))
                                .zIndex(2)
                            
                            Circle()
                                .fill(Color.green.opacity(1))
                                .frame(width: 33, height: 33)
                                .overlay(Circle().stroke(Color.appMint, lineWidth: 2))
                                .zIndex(1)
                            ZStack {
                                    Circle()
                                    .fill(Color.white.opacity(1))
                                    
                                    Text("+2")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundStyle(Color(red: 68/255, green: 68/255, blue: 68/255, opacity: 1))
                                }
                                .frame(width: 33, height: 33)
                                .overlay(Circle().stroke(Color.appMint, lineWidth: 2))
                                .padding(.leading, 10)
                                .zIndex(0)
                        }
                
            }
        .listRowBackground(
            Color(red: 230/255, green: 237/255, blue: 236/255)
            
            )
        }
        
    }

