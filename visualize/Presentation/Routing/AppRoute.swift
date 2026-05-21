//
//  AppRoute.swift
//  visualize
//
//  Created by Libia Fv on 10/05/26.
//

enum AppRoute: Hashable {
    case login
    case signUp
    case resetPassword
    case checkEmail(email: String)
    case generatingVisualizations
    case vizReady
    case notifications
}

enum RootRoute {
    case landing
}
