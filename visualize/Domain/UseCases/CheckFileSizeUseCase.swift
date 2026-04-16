//
//  CheckFileSizeUseCase.swift
//  VisualizeApp
//
//  Created by Libia Fv on 14/04/26.
//

import Foundation

struct CheckFileSizeUseCase {

    private let maxSize: Int64 =
        100 * 1024 * 1024

    func execute(size: Int64) -> Bool {

        return size <= maxSize
    }
}

