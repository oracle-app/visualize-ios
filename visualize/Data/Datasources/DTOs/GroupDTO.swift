//
//  GroupDTO.swift
//  visualize
//
//  Created by Carlos Amador on 18/04/26.
//

import FirebaseFirestore

struct GroupDTO: Codable {
    @DocumentID var id: String?
    let membersID: [DocumentReference]
    let name: String
    let ownerID: DocumentReference
}
