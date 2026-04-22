import SwiftUI

struct ShareSheet: View {
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 32)
                .fill(.thinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                Text("Personal feed")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color.primaryBlue)
                    .frame(width: 330, height: 44)
                    .background(.white)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.primaryBlue, lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                
                List {
                    
                    Section {
                        TeamRow()
                        
                        TeamRow()
                        
                    } header: {
                        Text("My teams")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color.primaryText)
                            .textCase(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, -16)
                    }
                    
                    Section {
                        TeamRow()
                        
                        TeamRow()
                        
                    } header: {
                        Text("Teams I’m in")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color.primaryText)
                            .textCase(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, -16)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(maxHeight: .infinity)
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}
