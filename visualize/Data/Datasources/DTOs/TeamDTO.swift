//
//  TeamDTO.swift
//  visualize
//
//  Created by Carlos Amador on 25/04/26.
//

import FirebaseFirestore

struct TeamDTO: Codable {
    @DocumentID
    var id: String?
    let name: String
    let ownerID: String
    let membersIDs: [String]
}
