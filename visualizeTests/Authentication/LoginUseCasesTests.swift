//
//  LoginUseCasesTests.swift
//  visualize
//
//  Created by Libia Fv on 06/06/26.
//
//  Test Plan Coverage: AUTH-001 → AUTH-005
//  Layer: Domain — Unit Tests (no Firebase, no network)
//
//  These tests validate the LoginUseCase in complete isolation.
//  All Firebase interactions are replaced by MockAuthRepository,
//  so no network connection or emulator is required to run them.
//

import XCTest
@testable import visualize

// MARK: - LoginUseCase Tests

/// Unit tests for `LoginUseCase`, covering input validation and repository delegation.
///
/// **Test IDs covered:** AUTH-001 → AUTH-005
///
/// Each test follows the **Given / When / Then** pattern:
/// - **Given** – preconditions and mock configuration.
/// - **When**  – the use case is executed.
/// - **Then**  – the result or thrown error is asserted.
final class LoginUseCaseTests: XCTestCase {

    // MARK: - Properties

    /// The system under test. Recreated before every test to guarantee isolation.
    var sut: LoginUseCase!

    /// Configurable mock that replaces the real `AuthRepository`.
    /// Controls what the use case receives back without touching Firebase.
    var mockRepo: MockAuthRepository!

    // MARK: - Lifecycle

    /// Initialises a fresh `sut` and `mockRepo` before each test method runs.
    override func setUp() {
        super.setUp()
        mockRepo = MockAuthRepository()
        sut = LoginUseCase(repository: mockRepo)
    }

    /// Releases all objects after each test to prevent state leaking between runs.
    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - AUTH-001

    /// **AUTH-001** – Login with valid credentials returns a populated `AuthUser`.
    ///
    /// The repository is pre-loaded with a known user. After a successful
    /// `execute`, the returned value must match exactly what the mock provided,
    /// confirming the use case forwards the result without modification.
    func test_login_withValidCredentials_returnsAuthUser() async throws {
        // Given
        let expectedUser = AuthUser(uid: "abc123", email: "libia@visualize.io")
        mockRepo.loginResult = expectedUser

        // When
        let result = try await sut.execute(email: "libia@visualize.io", password: "Correctpass1!")

        // Then
        XCTAssertEqual(result.uid, "abc123")
        XCTAssertEqual(result.email, "libia@visualize.io")
    }

    // MARK: - AUTH-002

    /// **AUTH-002** – Login with an empty email string throws `LoginError.emailRequired`.
    ///
    /// The use case must validate inputs before delegating to the repository,
    /// so the mock should never be reached in this scenario.
    func test_login_withEmptyEmail_throwsEmailRequired() async {
        do {
            _ = try await sut.execute(email: "", password: "Somepass1!")
            XCTFail("Should have thrown LoginError.emailRequired")
        } catch LoginError.emailRequired {
            // expected — empty email rejected before reaching the repository
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - AUTH-003

    /// **AUTH-003** – Login with a malformed email address throws `LoginError.invalidEmail`.
    ///
    /// Tests multiple invalid formats to ensure the validation rule is robust,
    /// not just sensitive to one specific pattern.
    func test_login_withInvalidEmailFormat_throwsInvalidEmail() async {
        let invalidEmails = ["notanemail", "missing@dot", "@nodomain.com", "spaces in@email.com"]

        for email in invalidEmails {
            do {
                _ = try await sut.execute(email: email, password: "Somepass1!")
                XCTFail("Should have thrown LoginError.invalidEmail for: \(email)")
            } catch LoginError.invalidEmail {
                // expected — malformed email rejected before reaching the repository
            } catch {
                XCTFail("Unexpected error for '\(email)': \(error)")
            }
        }
    }

    // MARK: - AUTH-004

    /// **AUTH-004** – Login with an empty password string throws `LoginError.passwordRequired`.
    ///
    /// Password presence must be checked independently of email validation,
    /// so a valid email combined with an empty password should still fail early.
    func test_login_withEmptyPassword_throwsPasswordRequired() async {
        do {
            _ = try await sut.execute(email: "valid@example.com", password: "")
            XCTFail("Should have thrown LoginError.passwordRequired")
        } catch LoginError.passwordRequired {
            // expected — empty password rejected before reaching the repository
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - AUTH-005

    /// **AUTH-005** – Login with wrong credentials propagates `LoginError.invalidCredentials`.
    ///
    /// When the repository (acting as Firebase) rejects the credentials,
    /// the use case must surface that error unchanged to the caller.
    func test_login_withWrongCredentials_throwsInvalidCredentials() async {
        // Given — repository simulates Firebase rejecting the credentials
        mockRepo.loginError = LoginError.invalidCredentials

        do {
            _ = try await sut.execute(email: "valid@example.com", password: "WrongPass1!")
            XCTFail("Should have thrown LoginError.invalidCredentials")
        } catch LoginError.invalidCredentials {
            // expected — repository error forwarded correctly
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Extra Test

    /// **Extra** – A correctly formatted email does not produce a format validation error.
    ///
    /// The repository is configured to throw `invalidCredentials`, which means
    /// the use case successfully passed format validation and reached the mock.
    /// If `invalidEmail` is thrown instead, the validator is rejecting a valid address.
    func test_login_withValidEmailFormat_doesNotThrowFormatError() async {
        // Given — repo throws invalidCredentials (reached the repo, so format was accepted)
        mockRepo.loginError = LoginError.invalidCredentials

        do {
            _ = try await sut.execute(email: "user@domain.co", password: "AnyPass1!")
        } catch LoginError.invalidEmail {
            XCTFail("Valid email should not throw invalidEmail")
        } catch {
            // Any other error (e.g. invalidCredentials) is acceptable here
        }
    }
}
