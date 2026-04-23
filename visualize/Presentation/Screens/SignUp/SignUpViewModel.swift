//
//  SignUpViewModel.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//
// Description:
//  ViewModel for the sign-up screen.
//  Stores user input values.

import Foundation
import Observation

@Observable
class SignUpViewModel {
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var errorMessage: String? = nil

    var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }

}
