//
//  CreateTeamUseCase.swift
//  visualize
//
//  Created by Libia Fv on 18/05/26.
//

import Foundation

// MARK: - Create Team Errors

/// Errors related to the team creation process.
enum CreateTeamError: Error {

    /// Thrown when the provided team name is empty
    /// after trimming whitespaces.
    case teamNameEmpty
    /// Thrown when the team has no non-owner members.
    case teamMembersEmpty
}

// MARK: - Create Team Use Case

/// Use case responsible for handling
/// the business logic of team creation.
///
/// Responsibilities:
/// - Validate the team name
/// - Ensure the owner is included in the team
/// - Remove duplicate members
/// - Delegate persistence to the repository layer
class CreateTeamUseCase {

    // MARK: - Dependencies

    /// Repository responsible for team persistence operations.
    private let teamRepository: any TeamRepository

    // MARK: - Initialization

    init(teamRepository: any TeamRepository) {
        self.teamRepository = teamRepository
    }

    // MARK: - Execute

    /// Creates a new team.
    ///
    /// Parameters:
    /// - name: Team name entered by the user.
    /// - ownerID: ID of the team owner.
    /// - memberIDs: List of selected member IDs.
    ///
    /// Behavior:
    /// - Trims extra whitespaces from the team name
    /// - Validates that the name is not empty
    /// - Automatically includes the owner in the team
    /// - Removes duplicated members
    ///
    /// Throws:
    /// - `CreateTeamError.teamNameEmpty`
    ///   if the name is invalid.
    /// - `CreateTeamError.teamMembersEmpty`
    ///   if no non-owner members are selected.
    /// - Repository-related errors during creation.
    func execute(
        name: String,
        ownerID: String,
        memberIDs: [String]
    ) async throws {

        // Remove leading/trailing whitespaces.
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate team name.
        guard !trimmedName.isEmpty else {
            throw CreateTeamError.teamNameEmpty
        }
        
        guard !memberIDs.isEmpty else {
            throw CreateTeamError.teamMembersEmpty
        }
        // MARK: - Build Member List

        /// Owner is always included.
        ///
        /// Duplicates are removed in case the owner
        /// was manually added as a member.
        let allMemberIDs = ([ownerID] + memberIDs)
            .reduce(into: [String]()) { result, id in
                if !result.contains(id) {
                    result.append(id)
                }
            }

        // MARK: - Repository Call

        try await teamRepository.createTeam(
            name: trimmedName,
            ownerID: ownerID,
            initialMembers: allMemberIDs
        )
    }
}
