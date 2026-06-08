//
//  LogoutUseCasesTests.swift
//  visualize
//
//  Created by Libia Fv on 06/06/26.
//
//  Test Plan Coverage: AUTH-013
//  Layer: Domain — Unit Tests (no Firebase, no network)
//

import XCTest
@testable import visualize

// MARK: - LogoutUseCase Tests

/// Unit test suite for `LogoutUseCase`.
///
/// Validates the logout use case behavior at the domain layer using a
/// `MockAuthRepository` to fully isolate logic from Firebase and the network.
///
/// **Coverage:** AUTH-013
///
/// **Cases covered:**
/// - Successful logout → repository is invoked correctly.
/// - Repository failure → error is propagated to the caller.
final class LogoutUseCaseTests: XCTestCase {

    // MARK: - Properties

    /// System Under Test.
    var sut: LogoutUseCase!

    /// Simulated authentication repository that lets each test control
    /// logout behavior without touching real services.
    var mockRepo: MockAuthRepository!

    // MARK: - Lifecycle

    /// Sets up a fresh SUT and mock before every test.
    override func setUp() {
        super.setUp()
        mockRepo = MockAuthRepository()
        sut = LogoutUseCase(repository: mockRepo)
    }

    /// Tears down all instances after every test to prevent
    /// state leaking between cases.
    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - Tests

    /// AUTH-013: Verifies that executing the use case
    /// calls `logout` on the repository once and throws no error.
    ///
    /// **Given** a repository configured to complete without error.
    /// **When** `sut.execute()` is called.
    /// **Then** `mockRepo.logoutCalled` must be `true`.
    func test_logout_callsRepositoryLogout() throws {
        // When
        try sut.execute()

        // Then
        XCTAssertTrue(mockRepo.logoutCalled, "Should have called logout on the repository")
    }

    /// AUTH-013: Verifies that a repository failure during
    /// sign-out is propagated to the caller rather than swallowed silently.
    ///
    /// **Given** a repository configured to throw `SignOutError`.
    /// **When** `sut.execute()` is called.
    /// **Then** an error must be thrown.
    func test_logout_whenRepositoryFails_throwsError() {
        /// Lightweight local error that simulates a generic sign-out failure.
        struct SignOutError: Error {}
        mockRepo.logoutError = SignOutError()

        XCTAssertThrowsError(try sut.execute(),
                             "Should propagate the repository error when signing out")
    }
}
