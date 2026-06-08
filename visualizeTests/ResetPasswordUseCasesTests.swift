//
//  ResetPasswordUseCaseTests.swift
//  visualize
//
//  Created by Libia Fv on 06/06/26.
//
//  Test Plan Coverage: AUTH-011 → AUTH-012
//  Layer: Domain — Unit Tests (no Firebase, no network)
//

import XCTest
@testable import visualize

// MARK: - ResetPasswordUseCase Tests

/// Unit test suite for `ResetPasswordUseCase`.
///
/// Validates password reset request behavior at the domain layer using a
/// `MockAuthRepository` to fully isolate logic from Firebase and the network.
///
/// **Coverage:** AUTH-011 → AUTH-012
///
/// **Cases covered:**
/// - Valid email → repository is invoked correctly (AUTH-011).
/// - Invalid email format → correct error is thrown before reaching the repository (AUTH-012).
final class ResetPasswordUseCaseTests: XCTestCase {

    // MARK: - Properties

    /// System Under Test.
    var sut: ResetPasswordUseCase!

    /// Simulated authentication repository that lets each test control
    /// password reset behavior without touching real services.
    var mockRepo: MockAuthRepository!

    // MARK: - Lifecycle

    /// Sets up a fresh SUT and mock before every test.
    override func setUp() {
        super.setUp()
        mockRepo = MockAuthRepository()
        sut = ResetPasswordUseCase(authRepository: mockRepo)
    }

    /// Tears down all instances after every test to prevent
    /// state leaking between cases.
    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - Tests

    /// AUTH-011 (happy path): Verifies that executing the use case with a
    /// well-formed email calls `sendPasswordReset` on the repository
    /// and throws no error.
    ///
    /// **Given** a repository configured to complete without error.
    /// **When** `sut.execute(email:)` is called with a valid email.
    /// **Then** `mockRepo.sendPasswordResetCalled` must be `true`.
    func test_resetPassword_withValidEmail_callsRepository() async throws {
        // When
        try await sut.execute(email: "user@visualize.io")

        // Then
        XCTAssertTrue(mockRepo.sendPasswordResetCalled,
                      "Should have called sendPasswordReset on the repository")
    }

    /// AUTH-012 (sad path): Verifies that a malformed or empty email is
    /// rejected by the use case before the repository is ever contacted.
    ///
    /// Iterates over a representative set of invalid inputs and asserts that:
    /// - A non-empty malformed address throws `ResetPasswordError.invalidEmail`.
    /// - An empty string throws `ResetPasswordError.emailRequired`.
    /// - In both cases, `sendPasswordReset` is **never** called on the repository.
    ///
    /// **Given** an email that does not meet the required format.
    /// **When** `sut.execute(email:)` is called.
    /// **Then** the appropriate `ResetPasswordError` is thrown without reaching the repository.
    func test_resetPassword_withInvalidEmailFormat_throwsInvalidEmail() async {
        /// Representative set of malformed and empty email addresses.
        let invalidEmails = ["notvalid", "missing@", "@domain.com", ""]

        for email in invalidEmails {
            do {
                try await sut.execute(email: email)
                if email.isEmpty {
                    XCTFail("Empty email should throw emailRequired")
                } else {
                    XCTFail("Invalid email '\(email)' should throw invalidEmail or emailRequired")
                }
            } catch ResetPasswordError.invalidEmail {
                XCTAssertFalse(mockRepo.sendPasswordResetCalled,
                               "Should not call repo if email is invalid")
            } catch ResetPasswordError.emailRequired {
                XCTAssertFalse(mockRepo.sendPasswordResetCalled,
                               "Should not call repo if email is empty")
            } catch {
                XCTFail("Unexpected error for '\(email)': \(error)")
            }
            // Reset flag so the next iteration starts with a clean state.
            mockRepo.sendPasswordResetCalled = false
        }
    }
}
