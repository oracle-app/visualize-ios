//
//  UserDTO.swift
//  visualize
//
//  Created by Carlos Amador on 15/04/26.
//

import Foundation
import FirebaseFirestore

struct UserDTO: Codable, Sendable {
    @DocumentID var id: String?
    let chartTheme: String
    let email: String
    let notificationsEnabled: Bool
    let profilePictureURL: String
    let themePreference: String
    let tokens: [String]
    let userType: String
    let username: String

}
