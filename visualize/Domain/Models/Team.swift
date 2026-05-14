//
//  Team.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

struct Team: Identifiable, Hashable {
    let id: String
    let name: String
    let memberCount: Int
    let members: [AppUser]
}
