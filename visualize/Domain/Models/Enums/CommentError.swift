//
//  CommentError.swift
//  visualize
//
//  Created by Kimberly Marquez on 24/05/26.
//

import Foundation

enum CommentError: LocalizedError {
    case emptyContent
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .emptyContent: return "Content cannot be empty."
        case .unauthorized: return "You are not authorized to perform this action."
        }
    }
}
