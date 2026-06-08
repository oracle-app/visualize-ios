//
//  FeedUseCasesTests.swift
//  VisualizeTests
//
//  Unit tests for FeedScreenViewModel.
//  Covers: FEED-001, FEED-003, FEED-004, FEED-005, FEED-006,
//          FEED-007, FEED-008, FEED-009, FEED-010, FEED-011,
//          FEED-012, FEED-014
//

import XCTest
@testable import visualize


// MARK: - Test Suite

@MainActor
final class FeedUseCasesTests: XCTestCase {

    // MARK: - Properties

    var sut: FeedScreenViewModel!
    var mockLoad: MockLoadVisualizationsUseCase!
    var mockSearch: MockSearchVisualizationsUseCase!
    var mockHide: MockHideVisualizationUseCase!
    var mockDelete: MockDeleteVisualizationUseCase!
    var mockAuth: FeedMockAuthRepository!
    var mockNotifications: MockNotificationRepository!
    var mockUser: MockUserRepository!

    // MARK: - Setup / Teardown

    override func setUp() async throws {
        try await super.setUp()
        mockLoad        = MockLoadVisualizationsUseCase()
        mockSearch      = MockSearchVisualizationsUseCase()
        mockHide        = MockHideVisualizationUseCase()
        mockDelete      = MockDeleteVisualizationUseCase()
        mockAuth        = FeedMockAuthRepository()
        mockNotifications = MockNotificationRepository()
        mockUser        = MockUserRepository()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    /// Creates a fresh SUT and waits for `initializeUser` to complete.
    private func makeSUT(cards: [VisualizationCard] = []) async -> FeedScreenViewModel {
        mockLoad.stubbedItems = cards
        let vm = FeedScreenViewModel(
            loadVisualizationsUseCase: mockLoad!,
            searchVisualizationsUseCase: mockSearch!,
            hideVisualizationUseCase: mockHide!,
            deleteVisualizationUseCase: mockDelete!,
            authRepository: mockAuth!,
            notificationRepository: mockNotifications!,
            userRepository: mockUser!
        )
        // Allow async initialization to settle.
        try? await Task.sleep(for: .milliseconds(100))
        return vm
    }

    // MARK: - FEED-001 | Cargar visualizaciones del usuario

    /// Verifies that after a successful load the state is `.loaded` and
    /// the VisualizationCards list is non-empty.
    func test_FEED001_loadData_setsLoadedStateWithCards() async throws {
        // Arrange
        let cards = [VisualizationCard.make(id: "1"), VisualizationCard.make(id: "2")]
        sut = await makeSUT(cards: cards)

        // Assert
        if case .loaded(let items) = sut.state {
            XCTAssertEqual(items.count, 2, "Should render 2 VisualizationCards")
        } else {
            XCTFail("Expected .loaded state, got \(sut.state)")
        }
    }

    // MARK: - FEED-003 | Feed vacío

    /// When the use case returns an empty list the state must be `.empty`
    /// so that EmptyListView is presented.
    func test_FEED003_loadData_withEmptyResult_setsEmptyState() async throws {
        // Arrange – no cards
        sut = await makeSUT(cards: [])

        // Assert
        if case .empty = sut.state {
            // ✓
        } else {
            XCTFail("Expected .empty state, got \(sut.state)")
        }
    }

    // MARK: - FEED-004 | Error de red al cargar Feed

    /// When the use case throws, the state must transition to `.error`
    /// so that ErrorListView is shown.
    func test_FEED004_loadData_whenUseCaseThrows_setsErrorState() async throws {
        // Arrange
        mockLoad.shouldThrow = true
        sut = await makeSUT()

        // Assert
        if case .error = sut.state {
            // ✓
        } else {
            XCTFail("Expected .error state, got \(sut.state)")
        }
    }

    // MARK: - FEED-005 | Filtro 'Todas' las visualizaciones

    /// With filter `.all` every card in the cache should appear in `.loaded`.
    func test_FEED005_filterAll_showsAllCards() async throws {
        // Arrange – mix of own and shared
        let mine  = VisualizationCard.make(id: "mine",   authorID: "user-123")
        let theirs = VisualizationCard.make(id: "theirs", authorID: "other-user")
        sut = await makeSUT(cards: [mine, theirs])

        // Act
        sut.setVisualizationFilter(.all)

        // Assert
        if case .loaded(let items) = sut.state {
            XCTAssertEqual(items.count, 2, "Filter 'All' should show both cards")
        } else {
            XCTFail("Expected .loaded state")
        }
    }

    // MARK: - FEED-006 | Filtro 'Personales'

    /// With filter `.personal` only cards where authorID == currentUserID appear.
    func test_FEED006_filterPersonal_showsOnlyOwnCards() async throws {
        // Arrange
        let mine   = VisualizationCard.make(id: "mine",   authorID: "user-123")
        let theirs = VisualizationCard.make(id: "theirs", authorID: "other-user")
        sut = await makeSUT(cards: [mine, theirs])

        // Act – switch from .all (default after init) to .personal
        sut.setVisualizationFilter(.personal)

        // Assert
        if case .loaded(let items) = sut.state {
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items.first?.id, "mine", "Only cards owned by currentUser should appear")
        } else {
            XCTFail("Expected .loaded state")
        }
    }

    // MARK: - FEED-007 | Filtro 'Compartidas'

    /// With filter `.shared` only cards where authorID != currentUserID appear.
    func test_FEED007_filterShared_showsOnlySharedCards() async throws {
        // Arrange
        let mine   = VisualizationCard.make(id: "mine",   authorID: "user-123")
        let theirs = VisualizationCard.make(id: "theirs", authorID: "other-user")
        sut = await makeSUT(cards: [mine, theirs])

        // Act
        sut.setVisualizationFilter(.shared)

        // Assert
        if case .loaded(let items) = sut.state {
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items.first?.id, "theirs", "Only cards shared by others should appear")
        } else {
            XCTFail("Expected .loaded state")
        }
    }

    // MARK: - FEED-008 | Búsqueda por título (mínimo 2 caracteres)

    /// When searchQuery has ≥ 2 characters, searchResults should be filtered
    /// locally against titles in allVisualizations.
    func test_FEED008_search_withTwoOrMoreChars_filtersResultsByTitle() async throws {
        // Arrange
        let match   = VisualizationCard.make(id: "1", title: "Sales Report")
        let noMatch = VisualizationCard.make(id: "2", title: "Inventory")
        sut = await makeSUT(cards: [match, noMatch])

        // Act
        sut.searchQuery = "Sale"

        // Assert
        XCTAssertEqual(sut.searchResults.count, 1)
        XCTAssertEqual(sut.searchResults.first?.id, "1", "Only 'Sales Report' should match 'Sale'")
    }

    // MARK: - FEED-009 | Búsqueda con 1 carácter no ejecuta filtro

    /// A single character in searchQuery must leave searchResults empty
    /// without triggering any filtering.
    func test_FEED009_search_withOneChar_doesNotFilter() async throws {
        // Arrange
        let cards = [VisualizationCard.make(title: "Alpha"), VisualizationCard.make(title: "Beta")]
        sut = await makeSUT(cards: cards)

        // Act
        sut.searchQuery = "A"

        // Assert
        XCTAssertTrue(sut.searchResults.isEmpty, "searchResults must be empty for a 1-character query")
    }

    // MARK: - FEED-010 | Limpiar búsqueda

    /// After clearSearch(), searchQuery and searchResults must be reset
    /// and the feed should return to its filtered state.
    func test_FEED010_clearSearch_resetsQueryAndResults() async throws {
        // Arrange
        let cards = [VisualizationCard.make(title: "Alpha")]
        sut = await makeSUT(cards: cards)
        sut.searchQuery = "Al"
        XCTAssertFalse(sut.searchResults.isEmpty) // precondition

        // Act
        sut.clearSearch()

        // Assert
        XCTAssertEqual(sut.searchQuery, "", "searchQuery should be empty after clearSearch")
        XCTAssertTrue(sut.searchResults.isEmpty, "searchResults should be empty after clearSearch")
    }

    // MARK: - FEED-011 | Ocultar visualización compartida

    /// hideVisualization should call the use case and remove the card
    /// from allVisualizations (reflected in the loaded state).
    func test_FEED011_hideVisualization_removesCardAndShowsToast() async throws {
        // Arrange
        let shared = VisualizationCard.make(id: "shared-1", authorID: "other-user")
        let own    = VisualizationCard.make(id: "own-1",    authorID: "user-123")
        sut = await makeSUT(cards: [shared, own])

        // Act
        sut.hideVisualization(visualizationID: "shared-1")
        try await Task.sleep(for: .milliseconds(200))

        // Assert – card removed from state
        if case .loaded(let items) = sut.state {
            XCTAssertFalse(items.contains { $0.id == "shared-1" }, "Hidden card must be removed from feed")
        } else {
            XCTFail("Expected .loaded state after hide")
        }

        // Assert – toast shown
        XCTAssertNotNil(sut.currentToast, "A confirmation toast must appear after hiding")
        XCTAssertEqual(sut.currentToast?.type, .success)
    }

    // MARK: - FEED-012 | Eliminar visualización propia

    /// deleteVisualization should call the use case and remove the card
    /// from allVisualizations for everyone.
    func test_FEED012_deleteVisualization_removesCardFromAllVisualizations() async throws {
        // Arrange
        let own    = VisualizationCard.make(id: "own-1",    authorID: "user-123")
        let shared = VisualizationCard.make(id: "shared-1", authorID: "other-user")
        sut = await makeSUT(cards: [own, shared])

        // Act
        sut.deleteVisualization(visualizationID: "own-1")
        try await Task.sleep(for: .milliseconds(200))

        // Assert – card removed
        if case .loaded(let items) = sut.state {
            XCTAssertFalse(items.contains { $0.id == "own-1" }, "Deleted card must be removed for everyone")
        } else {
            XCTFail("Expected .loaded state after delete")
        }

        // Assert – success toast
        XCTAssertNotNil(sut.currentToast)
        XCTAssertEqual(sut.currentToast?.type, .success)
    }

    // MARK: - FEED-014 | Pull to refresh actualiza datos

    /// Calling loadData(forceRefresh: true) must clear the cache and
    /// invoke the use case to fetch fresh data.
    func test_FEED014_pullToRefresh_forcesReloadAndUpdatesData() async throws {
        // Arrange – initial load with 1 card
        let initial = VisualizationCard.make(id: "1", title: "Old")
        sut = await makeSUT(cards: [initial])

        // Swap stubbed response to simulate server returning updated data
        let updated = VisualizationCard.make(id: "2", title: "New")
        mockLoad.stubbedItems = [updated]
        let callCountBefore = mockLoad.executeCallCount

        // Act – simulate pull-to-refresh (forceRefresh: true)
        sut.loadData(forceRefresh: true)
        try await Task.sleep(for: .milliseconds(200))

        // Assert – use case was called again
        XCTAssertGreaterThan(mockLoad.executeCallCount, callCountBefore,
                             "loadVisualizationsUseCase should be called on force refresh")

        // Assert – UI reflects new data
        if case .loaded(let items) = sut.state {
            XCTAssertTrue(items.contains { $0.id == "2" }, "Feed should show updated data after pull-to-refresh")
        } else {
            XCTFail("Expected .loaded state after refresh")
        }
    }
}
