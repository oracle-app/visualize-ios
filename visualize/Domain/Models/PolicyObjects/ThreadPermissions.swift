//
//  ThreadPermissions.swift
//  visualize
//
//  Created by Carlos Amador on 30/05/26.
//

import Foundation

struct ThreadPermissions {
    let currentUserRole: Role
    let currentUserID: String
    let visualizationOwnerID: String

    func canDeleteComment(commentAuthorID: String) -> Bool {
        if currentUserRole == .admin {
            return true
        }
        
        if currentUserRole == .writer && currentUserID == visualizationOwnerID {
            return true
        }
        
        return currentUserID == commentAuthorID
    }
}
