//
//  CommentMapper.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation
import FirebaseFirestore 

extension CommentDTO {
    func toComment(threads: [ThreadReply] = [], resolvedAuthorName: String? = nil, resolvedAvatarURL: String? = nil) -> Comment {
        Comment(
            id: self.id ?? "",
            authorID: self.authorID,
            authorName: resolvedAuthorName,
            authorAvatarURL: resolvedAvatarURL,
            content: self.content,
            imageURL: self.imageURL,
            createdAt: self.createdAt,
            threads: threads,
        )
    }
}
