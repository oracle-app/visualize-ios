//
//  ShareTeammatesServiceProtocol.swift
//  visualize
//
//  Created by Diana Escalante on 22/04/26.
//

protocol ShareTeammatesServiceProtocol {
    func fetchUsers() async throws -> [User]
}
