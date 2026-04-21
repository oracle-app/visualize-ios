//
//  ErrorListView.swift
//  visualize
//
//  Created by Jorge Flores on 21/04/26.
//
import SwiftUI

struct ErrorListView: View {

    let retryAction: () -> Void

    var body: some View {
        VStack {
            Spacer()

            VStack {
                Text("Error")
                    .font(.body.bold())
                    .foregroundStyle(Color.primaryAzul)

                Text("An error has happened")
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.bordered)
            .frame(width: 300, height: 50)
            .controlSize(.large)
            .background(Color.primaryAzul)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding(.bottom, 100)
        }
        .hCenter()
    }
}
