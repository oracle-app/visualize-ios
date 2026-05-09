//
//  FullScreenViewModel.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 27/04/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
class FullScreenViewModel {
    var title : String? = nil
    var author : String? = nil
    var createdAt: String? = nil
    var sharedWith: [Color]? = nil
    
    var team: Team?
      var isLoading: Bool = false
      var error: String?
      
      private let teamRepository: any TeamRepository
      private let userID = "e9Nk8XrxHJAtwN3Hf2FL"
      
      init(teamRepository: any TeamRepository) {
          self.teamRepository = teamRepository
      }
      
    func load(teamId: String) async {
        isLoading = true
        error = nil
        do {
            let owned = try await teamRepository.getTeamsUserOwns(userID: userID)
            let joined = try await teamRepository.getTeamsUserIsIn(userID: userID)
            let all = owned + joined
            team = all.first { $0.id == teamId }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
      
      var members: [AppUser] {
          team?.members ?? []
      }
}
