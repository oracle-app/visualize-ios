//
//  TeamsViewModel.swift
//  visualize
//
//  Created by Diana Escalante on 18/05/26.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class TeamsScreenViewModel {

    // MARK: - State

    private(set) var myTeams: [Team] = []
    private(set) var joinedTeams: [Team] = []
    private(set) var isLoading = false
    private(set) var error: String?

    // MARK: - Dependencies

    private let teamRepository: any TeamRepository
    private let authRepository: any AuthRepository
    private var userID: String = ""

    // MARK: - Init

    init(teamRepository: any TeamRepository, authRepository: any AuthRepository) {
        self.teamRepository = teamRepository
        self.authRepository = authRepository
    }
}
