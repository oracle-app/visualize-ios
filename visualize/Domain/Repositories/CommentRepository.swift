//
//  CommentRepository.swift
//  visualize
//
//  Created by Nicolas Peralta on 15/05/26.
//

import Foundation

/// Contract for posting snip comments associated with a visualization thread.
protocol CommentRepository {
    func postSnipComment(visualizationID: String, authorID: String, imageURL: URL, authorName: String) async throws
}
