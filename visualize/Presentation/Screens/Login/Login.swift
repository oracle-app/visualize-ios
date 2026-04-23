//
//  Login.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//
// Description:
//  Login screen built using SwiftUI.
//  Presents a structured user interface
//  with input fields for email and password,
//  along with text and layout elements
//  for a consistent visual experience.

import SwiftUI

struct Login: View {

    @State private var viewModel = LoginViewModel()
    @State private var isPasswordVisible = false

    var body: some View {
        VStack(spacing: 0) {

            ZStack {
                Image("LoginBackg")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .padding(.bottom, 40)
            }
            .frame(height: 110)

            ScrollView {
                VStack(spacing: 0) {

                    Text("Welcome")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(Color.appNavy))
                        .multilineTextAlignment(.center)
                        .padding(.top, 58)
                        .padding(.bottom, 58)

                    InputField(
                        placeholder: "Email",
                        text: $viewModel.email,
                        keyboardType: .emailAddress
                    )
                    .padding(.bottom, 28)

                    PasswordField(
                        placeholder: "Password",
                        text: $viewModel.password,
                        isVisible: $isPasswordVisible
                    )
                    .padding(.bottom, 8)

                    HStack {
                        Spacer()
                        Button {
                            // functionality
                        } label: {
                            Text("Forgot your password?")
                                .font(.system(size: 13))
                                .foregroundColor(Color(Color.appSubtitle))
                                .underline()
                        }
                    }
                    .padding(.bottom, 36)

                    AuthButton(title: "Log in", isEnabled: viewModel.isFormValid) {
                        // functionality
                    }
                    .padding(.bottom, 20)

                    VStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(Color(Color.appSubtitle))
                        Button {
                        } label: {
                            Text("Sign up")
                                .font(.system(size: 15))
                                .foregroundColor(Color(red: 192/255, green: 130/255, blue: 60/255))
                                .underline()
                        }
                    }
                    .padding(.bottom, 16)

                    Text("V 1.0.0")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 121/255, green: 139/255, blue: 138/255).opacity(0.6))
                        .padding(.top, 129)
                }
                .scrollTargetLayout()
                .padding(.horizontal, 24)
            }
            .background(Color(red: 245/255, green: 244/255, blue: 242/255))
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .ignoresSafeArea(edges: .bottom)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color(Color.appTeal))
    }
}

#Preview {
    Login()
}

