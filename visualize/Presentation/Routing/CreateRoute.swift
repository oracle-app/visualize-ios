//
//  CreateRoute.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 20/05/26.
//

// MARK: - Create Route

/// Navigation destinations within the Create tab.
///`CreateRoute` values are pushed onto `AppCoordinator.createPath` and resolved by the `navigationDestination(for: CreateRoute.self)`
/// registered inside the Create tab's `NavigationStack` in `NavBar`.

enum CreateRoute: Hashable {
    case generatingVisualizations
    case vizReady
}
