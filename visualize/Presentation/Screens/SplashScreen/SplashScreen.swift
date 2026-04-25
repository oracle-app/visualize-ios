//
//  SplashScreen.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//
// Description:
// The SplashScreen is the initial landing view of VisualizeApp, featuring a teal header and background image.
// It highlights the app name "Visualize" and the tagline "Turn data into decisions." to communicate its purpose.
// It includes authentication actions with "Log in" and "Sign up" buttons.
// A small version label is shown at the bottom.

import SwiftUI

struct SplashScreen: View {

    var body: some View {
        VStack(spacing: 0) {

            ZStack(alignment: .bottom) {
                Color(Color.appTeal)
                    .ignoresSafeArea(edges: .top)

                Image("SplashBackg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(edges: .top)
                    .opacity(0.4)
            }
            .frame(height: 240)

            VStack(spacing: 0) {

                VStack(spacing: 6) {
                    Text("Visualize")
                        .font(.system(size: 60, weight: .semibold))
                        .foregroundColor(Color.appNavy)
                        .tracking(5)
                        .padding(.top, 70)

                    Text("Turn data into decisions.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.appSubtitle)
                }
                .padding(.bottom, 32)

                Text("Create, choose, and share AI-powered\ngraphs in seconds.\nFast, simple, and secure.")
                    .font(.system(size: 15))
                    .foregroundColor(Color.appNavy)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                    } label: {
                        Text("Log in")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 280)
                            .frame(height: 50)
                            .shadow(radius: 10, x: 0, y: 2)
                            .background(
                                Capsule()
                                    .fill(Color.appTeal)
                            )
                    }
                    .padding(.bottom, 20)

                    Button {
                    } label: {
                        Text("Sign up")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color.appTeal)
                            .frame(maxWidth: 280)
                            .frame(height: 50)
                            .shadow(radius: 10, x: 0, y: 2)
                            .background(
                                Capsule()
                                    .strokeBorder(
                                        Color.appTeal,
                                        lineWidth: 1.5
                                    )
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)

                Text("V 1.0.0")
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 121/255, green: 139/255, blue: 138/255).opacity(0.6))
                    .padding(.bottom, 55)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 245/255, green: 244/255, blue: 242/255))
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .ignoresSafeArea(edges: .bottom)
        }
        .background(Color.appTeal)
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    SplashScreen()
}
