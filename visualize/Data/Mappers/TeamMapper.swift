//
//  TeamMapper.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

import Foundation

extension TeamDTO {
    func toTeam(members: [AppUser]) -> Team {
        guard let id = self.id else { fatalError("TeamDTO must have an ID.") }
        return Team(
            id: id,
            name: self.name,
            ownerID: self.ownerID,
            memberCount: members.count,
            members: members
        )
    }
}
