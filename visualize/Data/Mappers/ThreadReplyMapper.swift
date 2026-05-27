//
//  ThreadReplyMapper.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation
import FirebaseCore

extension ThreadReplyDTO {
    func toThreadReply(resolvedAuthorName: String? = nil, resolvedAvatarURL: String? = nil) -> ThreadReply {
        ThreadReply(
            id: self.id,
            authorID: self.authorID,
            authorName: resolvedAuthorName ?? self.authorName ?? "",
            authorAvatarURL: resolvedAvatarURL ?? self.authorAvatarURL,
            createdAt: self.createdAt,
            content: self.content,
            timeAgo: self.createdAt.dateValue().timeAgoDisplay()
        )
    }
}
