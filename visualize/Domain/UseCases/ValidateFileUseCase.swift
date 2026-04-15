//
//  ValidateFileUseCase.swift
//  visualize
//
//  Created by Carlos Amador on 12/04/26.
//

import Foundation

struct ValidateFileUseCase {
    private let allowedExtensions = ["xlsx", "csv"]
    
    func execute(url: URL) -> Bool {
        let extensionName = url.pathExtension.lowercased()
        return allowedExtensions.contains(extensionName)
    }
}
