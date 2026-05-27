//
//  LandingScreen.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//
// MARK: - Description
//
// The LandingScreen serves as the initial landing view of VisualizeApp.
//
// This screen:
// - Displays the app branding and tagline
// - Uses a themed authentication background image
// - Presents the Visualize logo prominently in the header
// - Provides primary authentication actions for logging in and signing up
// - Shows the current app version at the bottom of the screen
//

import SwiftUI

// MARK: - Splash Screen View

struct LandingScreen: View {
    @Environment(AppCoordinator.self) private var coordinator

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            ZStack(alignment: .bottom) {
                Color(Color.appTeal)
//                    .ignoresSafeArea(edges: .top)

                Image("AuthBackground")
                    .resizable()
                    .scaledToFill()
//                    .ignoresSafeArea(edges: .top)
                    .opacity(0.4)
                    .clipped()

                Image("VisualizeLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 350)
                    .frame(height: 120)
                    .padding(.bottom, 45)
            }
            .frame(height: 240)

            VStack(spacing: 0) {

                VStack(spacing: 6) {
                    Text("Visualize")
                        .font(.system(size: 60, weight: .semibold))
                        .foregroundColor(Color.appNavy)
                        .tracking(5)
                        .padding(.top, 70)

                    Text(String(localized: "Turn data into decisions."))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.appSubtitle)
                }
                .padding(.bottom, 32)

                Text(String(localized: "Create, choose, and share AI-powered\ngraphs in seconds.\nFast, simple, and secure."))
                    .font(.system(size: 15))
                    .foregroundColor(Color.appNavy)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        coordinator.push(.login)
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
                        coordinator.push(.signUp)
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
                    .foregroundColor(
                        Color(
                            red: 121/255,
                            green: 139/255,
                            blue: 138/255
                        )
                        .opacity(0.6)
                    )
                    .padding(.bottom, 55)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .ignoresSafeArea(edges: .bottom)
        }
        .background(Color.appTeal)
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Preview

#Preview {
    LandingScreen()
        .environment(AppCoordinator())
}

