//
//  CommentMapper.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//
///  An architectural extension layer acting as a Data Mapper for Comment domain entities.
///
///  Responsibilities:
///  - Decouples the core database network infrastructure layer (DTOs) from the clean client Domain Model layer.
///  - Transforms data transfer records (`CommentDTO`) cleanly into localized operational models (`Comment`).
///  - Injects contextual real-time graph resolutions such as nested thread trees and async user profile assets.
///

import Foundation
import FirebaseFirestore 

extension CommentDTO {
    /// Maps an infrastructure-level `CommentDTO` data transfer object into a clean domain `Comment` model instance.
    ///
    /// - Parameters:
    ///   - threads: A collection of resolved child `ThreadReply` elements structural branch assets. Defaults to an empty collection `[]`.
    ///   - resolvedAuthorName: An optional pre-fetched profile display name string resolved from user collections. Defaults to `nil`.
    ///   - resolvedAvatarURL: An optional pre-fetched target asset location link pointing to user profile pictures. Defaults to `nil`.
    ///
    /// - Returns: A fully configured structural `Comment` entity ready for direct pipeline injection into SwiftUI display cells.
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
