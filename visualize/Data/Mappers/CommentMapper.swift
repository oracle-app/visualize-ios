//
//  CommentMapper.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation
import FirebaseCore

extension CommentDTO {
    func toComment(threads: [ThreadReply] = [], resolvedAuthorName: String? = nil, resolvedAvatarURL: String? = nil) -> Comment {
        Comment(
            id: self.id ?? "",
            authorID: self.authorID,
            authorName: resolvedAuthorName ?? self.authorName,
            authorAvatarURL: resolvedAvatarURL ?? self.authorAvatarURL,
            content: self.content,
            imageURL: self.imageURL,
            createdAt: self.createdAt,
            threads: threads,
            timeAgo: self.createdAt.dateValue().timeAgoDisplay()
        )
    }
}
