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
    
    var authMock: MockAuth!
    var locationServiceMock: MockLocationService!
    var viewModel: AppLaunchViewModel!
    var coordinatorMock: MockCoordinator!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        authMock = MockAuth()
        locationServiceMock = MockLocationService()

        coordinatorMock = MockCoordinator(type: WeatherAppScreen.launch)
        viewModel = AppLaunchViewModel(coordinator: coordinatorMock, locationService: locationServiceMock, auth: authMock)
    }

    override func tearDown() {
        super.tearDown()
        cancellables.removeAll()
        authMock = nil
        locationServiceMock = nil
        viewModel = nil
        coordinatorMock = nil
    }

    func testUserNotAuthenticated() {
        authMock.signedOut = true
        authMock.user = nil
        
        viewModel.registerAuthStateHandler()
        
        XCTAssertTrue(self.coordinatorMock.pushedPages.contains(where: { $0 as? WeatherAppScreen == WeatherAppScreen.authentication }))
    }
    
    func testUserAuthenticatedLocationDenied() {
        authMock.signedOut = false
        authMock.user = MockUser(uid: "Test")
        viewModel.registerAuthStateHandler()
        locationServiceMock.statusSubject.send(.denied)
            XCTAssertTrue(self.coordinatorMock.pushedPages.contains(where: { $0 as? WeatherAppScreen == WeatherAppScreen.locationAccess }))
    }
    
    func testUserAuthenticatedLocationAuthorized() {
        authMock.signedOut = false
        authMock.user = MockUser(uid: "Test")
        locationServiceMock.statusSubject.send(.authorized)
        
        viewModel.registerAuthStateHandler()
        
        XCTAssertTrue(self.coordinatorMock.pushedPages.contains(where: { $0 as? WeatherAppScreen == WeatherAppScreen.main }))
    }

    func testUserAuthenticatedLocationNotDetermined_UserDenied() {
        authMock.signedOut = false
        authMock.user = MockUser(uid: "Test")
        locationServiceMock.statusSubject.send(.notDetermined)
        viewModel.registerAuthStateHandler()
        locationServiceMock.statusSubject.send(.denied)
        
        XCTAssertTrue(self.coordinatorMock.pushedPages.contains(where: { $0 as? WeatherAppScreen == WeatherAppScreen.locationAccess }))
        XCTAssertTrue(self.locationServiceMock.requestWhenInUseAuthorizationCalled)
    }

    func testUserAuthenticatedLocationNotDetermined_UserGaveAccess() {
        authMock.signedOut = false
        authMock.user = MockUser(uid: "Test")
        locationServiceMock.statusSubject.send(.notDetermined)
        
        viewModel.registerAuthStateHandler()
        locationServiceMock.statusSubject.send(.authorized)
        
        XCTAssertTrue(self.coordinatorMock.pushedPages.contains(where: { $0 as? WeatherAppScreen == WeatherAppScreen.main }))
        XCTAssertTrue(self.locationServiceMock.requestWhenInUseAuthorizationCalled)
    }
}
