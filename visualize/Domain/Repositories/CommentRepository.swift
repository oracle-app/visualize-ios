//
//  CommentRepository.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//
//
//  Domain contract for comments used by the Snipping Tool share flow and thread
//  replies. It exposes operations for posting the snip-backed comment as well as
//  loading and mutating the surrounding comment/thread data.

import Foundation

/// Contract for posting snip comments associated with a visualization thread.
protocol CommentRepository {
    
    // MARK: - Comments
    func loadComments(visualizationID: String) async throws -> [Comment]
    func postComment(visualizationID: String, author: AppUser, content: String, imageURL: String?) async throws
    func deleteComment(visualizationID: String, commentID: String) async throws

    // MARK: - Threads
    func postReply(visualizationID: String, commentID: String, author: AppUser, content: String) async throws
    func deleteReply(visualizationID: String, commentID: String, replyID: String) async throws

    // MARK: - Snip
    
    func postSnipComment(visualizationID: String, authorID: String, imageURL: URL, authorName: String) async throws
}
