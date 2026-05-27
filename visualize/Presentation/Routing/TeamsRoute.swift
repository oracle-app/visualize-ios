//
//  TeamsRoute.swift
//  visualize
//
//  Created by Diana Escalante on 26/05/26.
//

// MARK: - Teams Route
 
/// Defines the navigation destinations within the Teams tab.
///
/// Kept separate from `AppRoute` (which covers the auth flow) so each tab
/// owns its own route enum, as described in the coordinator guidelines.
enum TeamsRoute: Hashable {
    case createTeam
}
