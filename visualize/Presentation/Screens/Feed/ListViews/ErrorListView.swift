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
                    .foregroundStyle(Color.appTeal)

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
            .background(Color.appTeal)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding(.bottom, 90)
            .padding(.top, 130)
        }
        .hCenter()
        .padding(.top, 200)
        .accessibilityElement()
        .accessibilityIdentifier("errorListView")
    }
}
