//
//  AuthenticationViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import XCTest
import Combine
@testable import Weather

@MainActor
final class AuthenticationViewModelTests: XCTestCase {
//    private var viewModel: AuthenticationViewModel!
//    private var mockAuth: MockAuth!
//    private var mockKeychain: MockKeychainManager!
//    private var cancellables: Set<AnyCancellable>!
//
//    override func setUp() {
//        super.setUp()
//        mockAuth = MockAuth()
//        mockKeychain = MockKeychainManager()
//        viewModel = AuthenticationViewModel(coordinator: Coordinator,
//                                            auth: mockAuth,
//                                            keychain: mockKeychain)
//        cancellables = []
//    }
//    
//    override func tearDown() {
//        viewModel = nil
//        mockAuth = nil
//        mockKeychain = nil
//        cancellables = nil
//        super.tearDown()
//    }
//    
//    func testSwitchFlow() {
//        viewModel.switchFlow()
//        XCTAssertEqual(viewModel.flow, .signUp)
//        
//        viewModel.switchFlow()
//        XCTAssertEqual(viewModel.flow, .login)
//    }
//    
//    func testAutofillPasswordSucceed() {
//        viewModel.password = "Test"
//        
//        let expectation = XCTestExpectation(description: "Successful search")
//        viewModel.$password
//            .dropFirst()
//            .sink { password in
//            XCTAssertEqual(password, "")
//            expectation.fulfill()
//        }
//        .store(in: &cancellables)
//        viewModel.autofillPassword()
//        wait(for: [expectation], timeout: 1.0)
//
//    }
//    
//    func testAutofillPasswordFail() {
//        viewModel.password = "Test"
//        
//        let expectation = XCTestExpectation(description: "Successful search")
//        let expectedResult = "Password"
//        mockKeychain.password = expectedResult
//        
//        viewModel.$password
//            .dropFirst()
//            .sink { password in
//            XCTAssertEqual(password, expectedResult)
//            expectation.fulfill()
//
//        }
//        .store(in: &cancellables)
//        viewModel.autofillPassword()
//        wait(for: [expectation], timeout: 1.0)
//    }
//    
//    func testReset() {
//        viewModel.email = "test@example.com"
//        viewModel.password = "password"
//        viewModel.confirmPassword = "password"
//        
//        viewModel.reset()
//        
//        XCTAssertEqual(viewModel.flow, .login)
//        XCTAssertEqual(viewModel.email, "")
//        XCTAssertEqual(viewModel.password, "")
//        XCTAssertEqual(viewModel.confirmPassword, "")
//    }
//    
//    func testIsValidLoginFlow() {
//        viewModel.flow = .login
//        viewModel.email = "test@example.com"
//        viewModel.password = "password"
//        XCTAssertTrue(viewModel.isValid)
//        
//        viewModel.email = ""
//        viewModel.password = "password"
//        XCTAssertFalse(viewModel.isValid)
//        
//        viewModel.email = "test@example.com"
//        viewModel.password = ""
//        XCTAssertFalse(viewModel.isValid)
//    }
//    
//    func testIsValidSignUpFlow() {
//        viewModel.flow = .signUp
//        viewModel.email = "test@example.com"
//        viewModel.password = "password"
//        viewModel.confirmPassword = "password"
//        XCTAssertTrue(viewModel.isValid)
//        
//        viewModel.email = ""
//        viewModel.password = "password"
//        viewModel.confirmPassword = "password"
//        XCTAssertFalse(viewModel.isValid)
//        
//        viewModel.email = "test@example.com"
//        viewModel.password = ""
//        viewModel.confirmPassword = "password"
//        XCTAssertFalse(viewModel.isValid)
//
//        viewModel.email = "test@example.com"
//        viewModel.password = "password"
//        viewModel.confirmPassword = ""
//        XCTAssertFalse(viewModel.isValid)
//    }
//    
//    func testSignInWithEmailPassword_Success() async {
//        let expectedMail = "test@example.com"
//        let expectedPass = "password"
//        mockAuth.user = MockUser(uid: "user")
//        viewModel.email = expectedMail
//        viewModel.password = expectedPass
//        
//        let result = await viewModel.signInWithEmailPassword()
//        
//        XCTAssertTrue(result)
//        XCTAssertEqual(mockKeychain.email, expectedMail)
//        XCTAssertEqual(mockKeychain.password, expectedPass)
//        XCTAssertEqual(mockKeychain.secClass, kSecClassGenericPassword)
//    }
//    
//    func testSignInWithEmailPassword_Failure() async {
//        mockAuth.user = nil
//        
//        let result = await viewModel.signInWithEmailPassword()
//        
//        XCTAssertFalse(result)
//        XCTAssertEqual(viewModel.authenticationState, .unauthenticated)
//    }
//    
//    func testSignUpWithEmailPassword_Success() async {
//        mockAuth.user = MockUser(uid: "User")
//        
//        let result = await viewModel.signUpWithEmailPassword()
//        
//        XCTAssertTrue(result)
//    }
//    
//    func testSignUpWithEmailPassword_Failure() async {
//        
//        let result = await viewModel.signUpWithEmailPassword()
//        
//        XCTAssertFalse(result)
//        XCTAssertEqual(viewModel.authenticationState, .unauthenticated)
//    }
}
