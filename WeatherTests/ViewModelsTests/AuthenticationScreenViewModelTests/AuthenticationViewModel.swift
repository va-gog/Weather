//
//  AuthenticationViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import XCTest
import Combine
import SwiftUI
@testable import Weather

@MainActor
final class AuthenticationViewModelTests: XCTestCase {
    private var viewModel: AuthenticationViewModel!
    private var mockAuth: MockAuth!
    private var mockKeychain: MockKeychainManager!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAuth = MockAuth()
        mockKeychain = MockKeychainManager()
        viewModel = AuthenticationViewModel(keychain: mockKeychain, auth: mockAuth)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockAuth = nil
        mockKeychain = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testSwitchFlow() {
        viewModel.send(AuthenticationViewAction.switchFlow)
        XCTAssertEqual(viewModel.state.flow, .signUp)
        
        viewModel.send(AuthenticationViewAction.switchFlow)
        XCTAssertEqual(viewModel.state.flow, .login)
    }
    
    func testAutofillPasswordFail() {
        viewModel.state.password = "Test"
        
        let expectation = XCTestExpectation(description: "Successful search")
        viewModel.state.$password
            .dropFirst()
            .sink { password in
            XCTAssertEqual(password, "")
            expectation.fulfill()
        }
        .store(in: &cancellables)
        viewModel.send(AuthenticationViewAction.autofillPassword)
        wait(for: [expectation], timeout: 1.0)

    }
    
    func testAutofillPasswordSuccess() {
        viewModel.state.password = "Test"
        
        let expectation = XCTestExpectation(description: "Successful search")
        let expectedResult = "Password"
        mockKeychain.password = expectedResult
        
        viewModel.state.$password
            .dropFirst()
            .sink { password in
            XCTAssertEqual(password, expectedResult)
            expectation.fulfill()

        }
        .store(in: &cancellables)
        viewModel.send(AuthenticationViewAction.autofillPassword)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testReset() {
        viewModel.state.email = "test@example.com"
        viewModel.state.password = "password"
        viewModel.state.confirmPassword = "password"
        
        viewModel.send(AuthenticationViewAction.reset)
        
        XCTAssertEqual(viewModel.state.flow, .login)
        XCTAssertEqual(viewModel.state.email, "")
        XCTAssertEqual(viewModel.state.password, "")
        XCTAssertEqual(viewModel.state.confirmPassword, "")
    }
    
    func testIsValidLoginFlow() {
        viewModel.state.flow = .login
        viewModel.state.email = "test@example.com"
        viewModel.state.password = "password"
        XCTAssertTrue(viewModel.state.isValid)
        
        viewModel.state.email = ""
        viewModel.state.password = "password"
        XCTAssertFalse(viewModel.state.isValid)
        
        viewModel.state.email = "test@example.com"
        viewModel.state.password = ""
        XCTAssertFalse(viewModel.state.isValid)
    }
    
    func testIsValidSignUpFlow() {
        viewModel.state.flow = .signUp
        viewModel.state.email = "test@example.com"
        viewModel.state.password = "password"
        viewModel.state.confirmPassword = "password"
        XCTAssertTrue(viewModel.state.isValid)
        
        viewModel.state.email = ""
        viewModel.state.password = "password"
        viewModel.state.confirmPassword = "password"
        XCTAssertFalse(viewModel.state.isValid)
        
        viewModel.state.email = "test@example.com"
        viewModel.state.password = ""
        viewModel.state.confirmPassword = "password"
        XCTAssertFalse(viewModel.state.isValid)

        viewModel.state.email = "test@example.com"
        viewModel.state.password = "password"
        viewModel.state.confirmPassword = ""
        XCTAssertFalse(viewModel.state.isValid)
    }
    
    func testLoginFlowIsValidWhenEmailAndPasswordAreNonEmpty() {
           viewModel.state.email = "test@example.com"
           viewModel.state.password = "password123"
           
           let expectation = XCTestExpectation(description: "isValid should be true")
           
           viewModel.state.$isValid
               .sink { isValid in
                   if isValid {
                       XCTAssertTrue(isValid)
                       expectation.fulfill()
                   }
               }
               .store(in: &cancellables)
           viewModel.state.flow = .login
           wait(for: [expectation], timeout: 1)
       }
       
       func testLoginFlowIsNotValidWhenEmailIsEmpty() {
           viewModel.state.email = ""
           viewModel.state.password = "password123"
           
           let expectation = XCTestExpectation(description: "isValid should be false")
           
           viewModel.state.$isValid
               .sink { isValid in
                   if !isValid {
                       XCTAssertFalse(isValid)
                       expectation.fulfill()
                   }
               }
               .store(in: &cancellables)
           viewModel.state.flow = .login
           wait(for: [expectation], timeout: 1)
       }
    
    func testSignInWithEmailPassword_Success() {
        let expectedMail = "test@example.com"
        let expectedPass = "password"
        mockAuth.user = MockUser(uid: "user")
        viewModel.state.email = expectedMail
        viewModel.state.password = expectedPass
        viewModel.state.flow = .login
        viewModel.send(AuthenticationViewAction.signAction)
        let expectation = XCTestExpectation(description: "Start location updates")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(self.mockAuth.signedInSucceed)
            XCTAssertEqual(self.mockKeychain.email, expectedMail)
            XCTAssertEqual(self.mockKeychain.password, expectedPass)
            XCTAssertEqual(self.mockKeychain.secClass, kSecClassGenericPassword)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

    }
    
    func testSignInWithEmailPassword_Failure() {
        mockAuth.user = nil
        viewModel.state.flow = .login

        viewModel.send(AuthenticationViewAction.signAction)

        XCTAssertFalse(mockAuth.signedInSucceed)
    }
    
    func testSignUpWithEmailPassword_Success() {
        mockAuth.user = MockUser(uid: "User")
        viewModel.state.flow = .signUp
        let expectation = XCTestExpectation(description: "Start location updates")

        viewModel.send(AuthenticationViewAction.signAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(self.mockAuth.signedInSucceed)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSignUpWithEmailPassword_Failure() async {
        viewModel.state.flow = .signUp
        
        viewModel.send(AuthenticationViewAction.signAction)

        XCTAssertFalse(mockAuth.signedInSucceed)
    }
}
