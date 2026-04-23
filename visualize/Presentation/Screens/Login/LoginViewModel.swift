//
//  LoginViewModel.swift
//  visualize
//
//  Created by Libia Fv on 19/04/26.
//
// Description:
//  ViewModel for the login screen.
//  Stores user input values such as email and password,
//  and provides simple state representation for the view.

import Foundation
import Observation

@Observable
class LoginViewModel {
    var email = ""
    var password = ""
    var errorMessage: String? = nil

    var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty
    }

}
