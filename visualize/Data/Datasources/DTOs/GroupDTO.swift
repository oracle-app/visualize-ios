//
//  TeamDTO.swift
//  visualize
//
//  Created by Carlos Amador on 18/04/26.
//

import FirebaseFirestore

struct TeamDTO: Codable {
    @DocumentID var id: String?
    let membersIDs: [String]
    let name: String
    let ownerID: String
}
