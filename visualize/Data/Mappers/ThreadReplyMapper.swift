//
//  ThreadReplyMapper.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation
import FirebaseFirestore 

extension ThreadReplyDTO {
    func toThreadReply(resolvedAuthorName: String? = nil, resolvedAvatarURL: String? = nil) -> ThreadReply {
        ThreadReply(
            id: self.id,
            authorID: self.authorID,
            authorName: resolvedAuthorName ?? "",
            authorAvatarURL: resolvedAvatarURL,
            createdAt: self.createdAt,
            content: self.content,
        )
    }
}
