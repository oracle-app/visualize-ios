//
//  RegisterUseCasesTests.swift
//  visualize
//
//  Created by Libia Fv on 06/06/26.
//
//  Test Plan Coverage: AUTH-006 → AUTH-010
//  Layer: Domain — Unit Tests (no Firebase, no network)
//
//  These tests validate RegisterUseCase in complete isolation.
//  All Firebase and Firestore interactions are replaced by
//  MockAuthRepository and MockUserRepositoryAuth, so no network
//  connection or emulator is required to run them.
//

import XCTest
@testable import visualize

// MARK: - RegisterUseCase Tests

/// Unit tests for `RegisterUseCase`, covering password validation,
/// duplicate email handling, and Firestore rollback on failure.
///
/// **Test IDs covered:** AUTH-006 → AUTH-010
///
/// Each test follows the **Given / When / Then** pattern:
/// - **Given** – preconditions and mock configuration.
/// - **When**  – the use case is executed.
/// - **Then**  – the result or thrown error is asserted.
final class RegisterUseCaseTests: XCTestCase {

    // MARK: - Properties

    /// The system under test. Recreated before every test to guarantee isolation.
    var sut: RegisterUseCase!

    /// Configurable mock that replaces the real `AuthRepository`.
    /// Controls Firebase auth responses (register success or failure).
    var mockAuthRepo: MockAuthRepository!

    /// Configurable mock that replaces the real `UserRepository`.
    /// Controls Firestore user creation responses (success or failure).
    var mockUserRepo: MockUserRepositoryAuth!

    // MARK: - Lifecycle

    /// Initialises a fresh `sut`, `mockAuthRepo`, and `mockUserRepo`
    /// before each test method runs.
    override func setUp() {
        super.setUp()
        mockAuthRepo = MockAuthRepository()
        mockUserRepo = MockUserRepositoryAuth()
        sut = RegisterUseCase(authRepository: mockAuthRepo, userRepository: mockUserRepo)
    }

    /// Releases all objects after each test to prevent state leaking between runs.
    override func tearDown() {
        sut = nil
        mockAuthRepo = nil
        mockUserRepo = nil
        super.tearDown()
    }

    // MARK: - AUTH-006

    /// **AUTH-006** – Successful registration returns a populated `AppUser`
    /// and does not trigger a rollback.
    ///
    /// When both Firebase auth and Firestore creation succeed, the use case
    /// must return the created user and must never call `deleteCurrentUser`,
    /// since there is nothing to roll back.
    func test_register_withValidInput_returnsAppUser() async throws {
        // Given
        mockAuthRepo.registerResult = AuthUser(uid: "new-uid", email: "new@visualize.io")

        // When
        let result = try await sut.execute(
            email: "new@visualize.io",
            password: "SecurePass1!",
            username: "NewUser"
        )

        // Then
        XCTAssertEqual(result.email, "new@visualize.io")
        XCTAssertEqual(result.username, "NewUser")
        XCTAssertFalse(mockAuthRepo.deleteCurrentUserCalled,
                       "Should not delete the user if creation was successful")
    }

    // MARK: - AUTH-007

    /// **AUTH-007** – Registration with a password shorter than 12 characters
    /// throws `RegisterError.passwordTooShort`.
    ///
    /// The use case must enforce the minimum length rule before reaching
    /// either the auth or user repositories.
    func test_register_withPasswordTooShort_throwsPasswordTooShort() async {
        do {
            _ = try await sut.execute(email: "a@b.com", password: "Short1!", username: "User")
            XCTFail("Should have thrown RegisterError.passwordTooShort")
        } catch RegisterError.passwordTooShort {
            // expected — short password rejected before reaching the repository
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// **AUTH-007 edge** – A password of exactly 11 characters is still too short
    /// and must throw `RegisterError.passwordTooShort`.
    ///
    /// Validates that the boundary condition is strict (minimum is 12, not 11).
    func test_register_with11CharPassword_throwsPasswordTooShort() async {
        do {
            _ = try await sut.execute(email: "a@b.com", password: "Abcdefg1!00", username: "User")
            XCTFail("11-char password should throw passwordTooShort")
        } catch RegisterError.passwordTooShort {
            // expected — 11 chars is below the 12-character minimum
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - AUTH-008

    /// **AUTH-008** – A password with no special characters throws
    /// `RegisterError.passwordNeedsSpecialCharacter`.
    ///
    /// The password meets the length requirement (≥ 12 chars) and contains
    /// both letters and numbers, but is missing at least one special character.
    func test_register_withoutSpecialCharacter_throwsPasswordNeedsSpecialChar() async {
        do {
            // >= 12 chars, has letters and numbers, but no special character
            _ = try await sut.execute(email: "a@b.com", password: "Abcdef123456", username: "User")
            XCTFail("Should have thrown RegisterError.passwordNeedsSpecialCharacter")
        } catch RegisterError.passwordNeedsSpecialCharacter {
            // expected — password missing a special character
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - AUTH-009

    /// **AUTH-009** – A password with no digits throws
    /// `RegisterError.passwordNeedsLettersAndNumbers`.
    ///
    /// The password meets the length requirement and contains a special character,
    /// but consists only of letters — no numeric characters are present.
    func test_register_withoutLettersAndNumbers_throwsPasswordNeedsLettersAndNumbers() async {
        do {
            // >= 12 chars, has special char, but only letters (no digits)
            _ = try await sut.execute(email: "a@b.com", password: "Abcdefghijk!", username: "User")
            XCTFail("Should have thrown RegisterError.passwordNeedsLettersAndNumbers")
        } catch RegisterError.passwordNeedsLettersAndNumbers {
            // expected — password missing numeric characters
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - AUTH-010

    /// **AUTH-010** – Attempting to register with an already-used email
    /// propagates `RegisterError.emailAlreadyInUse`.
    ///
    /// The auth repository simulates Firebase rejecting a duplicate email.
    /// The use case must surface that error unchanged to the caller.
    func test_register_withAlreadyUsedEmail_throwsEmailAlreadyInUse() async {
        // Given — auth repo simulates Firebase rejecting the duplicate email
        mockAuthRepo.registerError = RegisterError.emailAlreadyInUse

        do {
            _ = try await sut.execute(
                email: "existing@visualize.io",
                password: "ValidPass1!AB",
                username: "AnotherUser"
            )
            XCTFail("Should have thrown RegisterError.emailAlreadyInUse")
        } catch RegisterError.emailAlreadyInUse {
            // expected — duplicate email rejected by the repository
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Extra Tests

    /// **Extra** – If Firestore user creation fails after a successful Firebase
    /// auth registration, the use case must roll back by deleting the auth account.
    ///
    /// This prevents orphaned Firebase Auth accounts that have no corresponding
    /// Firestore document, which would leave the app in an inconsistent state.
    func test_register_whenCreateUserFails_rollsBackAuthAccount() async {
        // Given — auth succeeds, but Firestore fails when creating the document
        struct FirestoreError: Error {}
        mockUserRepo.createUserError = FirestoreError()

        do {
            _ = try await sut.execute(
                email: "a@b.com",
                password: "ValidPass1!AB",
                username: "User"
            )
            XCTFail("Should propagate the Firestore error")
        } catch {
            XCTAssertTrue(mockAuthRepo.deleteCurrentUserCalled,
                          "Must call deleteCurrentUser as rollback if createUser fails")
        }
    }

    /// **Extra** – An empty email string during registration throws
    /// `RegisterError.emailRequired`.
    ///
    /// Email presence must be validated before any repository is reached,
    /// consistent with how LoginUseCase handles the same condition.
    func test_register_withEmptyEmail_throwsEmailRequired() async {
        do {
            _ = try await sut.execute(email: "", password: "ValidPass1!AB", username: "User")
            XCTFail("Should throw RegisterError.emailRequired")
        } catch RegisterError.emailRequired {
            // expected — empty email rejected before reaching the repository
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
