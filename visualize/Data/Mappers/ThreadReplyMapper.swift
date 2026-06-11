//
//  ThreadReplyMapper.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//
///  An architectural extension layer acting as a Data Mapper for ThreadReply domain entities.
///
///  Responsibilities:
///  - Decouples the low-level database data transfer objects (DTOs) from the presentation domain models.
///  - Transforms a flat structural network payload (`ThreadReplyDTO`) into an isolated domain node (`ThreadReply`).
///  - Provides seamless injection mechanics for externally resolved asynchronous identity attributes like user display names and avatars.
//

import Foundation
import FirebaseFirestore 

extension ThreadReplyDTO {
    /// Maps an infrastructure-level `ThreadReplyDTO` data transfer object into a clean domain `ThreadReply` model instance.
    ///
    /// - Parameters:
    ///   - resolvedAuthorName: An optional pre-fetched identity display name string resolved from user profile records. Defaults to `nil`.
    ///   - resolvedAvatarURL: An optional pre-fetched target asset location link pointing to the user's remote profile picture. Defaults to `nil`.
    ///
    /// - Returns: A fully configured structural `ThreadReply` entity prepared for rendering inside nested timeline row views.
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
