//
//  VisualizationPermissions.swift
//  visualize
//
//  Created by Carlos Amador on 23/05/26.
//

import Foundation

struct VisualizationPermissions: Sendable, Hashable, Equatable {
    let canDelete: Bool
    let canHide: Bool
    let canShare: Bool
    
    init(userRole: Role, currentUserID: String, authorID: String) {
        let isOwner = currentUserID == authorID
        
        switch userRole {
        case .admin:
            self.canDelete = true
            self.canHide = !isOwner
            self.canShare = true
            
        case .writer:
            self.canDelete = isOwner
            self.canHide = !isOwner
            self.canShare = isOwner
            
        case .consumer:
            self.canDelete = false
            self.canHide = true
            self.canShare = false
        }
    }
}
