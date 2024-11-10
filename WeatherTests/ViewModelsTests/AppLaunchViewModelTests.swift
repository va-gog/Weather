//
//  AppLaunchViewModelTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 09.11.24.
//

import XCTest
import Combine
@testable import Weather

class AppLaunchViewModelTests: XCTestCase {

    var viewModel: AppLaunchViewModel!
    var coordinatorMock: MockCoordinator!
    var dependenciesMock: MockDependencyManager!
    var authMock: MockAuth!
    var locationServiceMock: MockLocationService!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        authMock = MockAuth()
        locationServiceMock = MockLocationService()
        dependenciesMock = MockDependencyManager(auth: authMock,
                                                 locationService: locationServiceMock)
        coordinatorMock = MockCoordinator(dependenciesManager: dependenciesMock)
        viewModel = AppLaunchViewModel(coordinator: coordinatorMock)
    }

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testUserNotAuthenticated() {
        authMock.signedOut = true
        authMock.user = nil
        
        viewModel.registerAuthStateHandler()
        
        XCTAssertEqual(self.coordinatorMock.pushedPage, AppPages.authentication)
    }
    
    func testUserAuthenticatedLocationDenied() {
        authMock.signedOut = false
        authMock.user = MockUser(uid: "Test")
        locationServiceMock.statusSubject.send(.denied)
        
        self.viewModel.registerAuthStateHandler()
        
        XCTAssertEqual(self.coordinatorMock.popAction, PopAction.authentication)
        XCTAssertEqual(self.coordinatorMock.pushedPage, AppPages.locationAccess)
    }
    
    func testUserAuthenticatedLocationAuthorized() {
        authMock.signedOut = false
        authMock.user = MockUser(uid: "Test")
        locationServiceMock.statusSubject.send(.authorized)
        
        viewModel.registerAuthStateHandler()
        
        XCTAssertEqual(self.coordinatorMock.popAction, PopAction.authentication)
        XCTAssertEqual(self.coordinatorMock.pushedPage, AppPages.main)
    }

    func testUserAuthenticatedLocationNotDetermined_UserDenied() {
        let expectation = XCTestExpectation(description: "Location access denied")

        authMock.signedOut = false
        authMock.user = MockUser(uid: "Test")
        locationServiceMock.statusSubject.send(.notDetermined)
        viewModel.registerAuthStateHandler()
        locationServiceMock.statusSubject.send(.denied)

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.coordinatorMock.popAction, PopAction.last)
            XCTAssertEqual(self.coordinatorMock.pushedPage, AppPages.locationAccess)
            XCTAssertTrue(self.locationServiceMock.requestWhenInUseAuthorizationCalled)

            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }

    func testUserAuthenticatedLocationNotDetermined_UserGaveAccess() {
        let expectation = XCTestExpectation(description: "Location access denied")

        authMock.signedOut = false
        authMock.user = MockUser(uid: "Test")
        locationServiceMock.statusSubject.send(.notDetermined)
        
        viewModel.registerAuthStateHandler()
        locationServiceMock.statusSubject.send(.authorized)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.coordinatorMock.popAction, PopAction.last)
            XCTAssertEqual(self.coordinatorMock.pushedPage, AppPages.main)
            XCTAssertTrue(self.locationServiceMock.requestWhenInUseAuthorizationCalled)

            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
