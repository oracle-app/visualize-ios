//
//  CommentRepository.swift
//  visualize
//

import Foundation

protocol CommentRepository {
    func postSnipComment(visualizationID: String, authorID: String, imageURL: URL) async throws
}
