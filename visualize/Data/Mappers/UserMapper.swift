//
//  UserMapper.swift
//  visualize
//
//  Created by Carlos Amador on 18/04/26.
//

import Foundation
internal import FirebaseFirestoreInternal

extension UserDTO {
    func toAppUser() -> AppUser {
        return AppUser(
            id: self.id.flatMap {UUID(uuidString: $0)} ?? UUID (),
            email: self.email,
            profilePictureURL: self.profilePictureURL,
            username: self.username
        )
    }
}
