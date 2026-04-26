//
//  UserMapper.swift
//  visualize
//
//  Created by Carlos Amador on 18/04/26.
//

import Foundation

extension UserDTO {
    func toAppUser() -> AppUser {
        guard let id = self.id else { fatalError("UserDTO must have an id") }
        return AppUser(
            id: id,
            email: self.email,
            profilePictureURL: self.profilePictureURL,
            username: self.username
        )
    }
}
