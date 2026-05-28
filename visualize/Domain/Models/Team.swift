//
//  Team.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

struct Team: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let ownerID: String
    let memberCount: Int
    let members: [AppUser]
}
