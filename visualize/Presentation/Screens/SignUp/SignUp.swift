//
//  SignUp.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//
// Description:
//  SwiftUI view for account creation.
//  Features a structured layout with input fields
//  for user details and a cohesive style.
//

import SwiftUI

struct SignUp: View {

    @State private var viewModel = SignUpViewModel()
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false

    var body: some View {
        VStack(spacing: 0) {

            ZStack {
                Image("SignUpBackg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipped()
            }
            .frame(height: 110)

            ScrollView {
                VStack(spacing: 0) {

                    Text("Create your account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(Color.appNavy))
                        .multilineTextAlignment(.center)
                        .padding(.top, 58)
                        .padding(.bottom, 58)

                    InputField(
                        placeholder: "Name",
                        text: $viewModel.name
                    )
                    .padding(.bottom, 28)

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

                    PasswordField(
                        placeholder: "Confirm password",
                        text: $viewModel.confirmPassword,
                        isVisible: $isConfirmPasswordVisible
                    )
                    .padding(.bottom, 36)

                    AuthButton(title: "Sign up", isEnabled: viewModel.isFormValid) {
                        // functionality
                    }
                    .padding(.bottom, 20)

                    VStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(Color(Color.appSubtitle))
                        Button {
                        } label: {
                            Text("Log in")
                                .font(.system(size: 15))
                                .foregroundColor(Color(red: 192/255, green: 130/255, blue: 60/255))
                                .underline()
                        }
                    }
                    .padding(.bottom, 16)

                    Text("V 1.0.0")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 121/255, green: 139/255, blue: 138/255).opacity(0.6))
                        .padding(.bottom, 40)
                }
                .scrollTargetLayout()
                .padding(.horizontal, 24)
            }
            .background(Color(red: 245/255, green: 244/255, blue: 242/255))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .ignoresSafeArea(edges: .bottom)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color(Color.appTeal))
    }
}

#Preview {
    SignUp()
}
