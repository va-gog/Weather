//
//  WeatherAppViewModelTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

import XCTest
import Combine
import CoreLocation
@testable import Weather

final class WeatherAppViewModelTests: XCTestCase {
    
    var viewModel: WeatherAppViewModel!
    var mockNetworkManager: MockNetworkManager!
    var mockLocationService: MockLocationService!
    var mockNotificationFactory: MockUserNotificationsFactory!
    var mockDependencyManager: MockDependencyManager!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockLocationService = MockLocationService()
        mockNotificationFactory = MockUserNotificationsFactory()
        mockDependencyManager = MockDependencyManager(networkService: mockNetworkManager,
                                                      locationService: mockLocationService,
                                                      notificationFactory: mockNotificationFactory)
        viewModel = WeatherAppViewModel(dependencyManager: mockDependencyManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        mockLocationService = nil
        mockNotificationFactory = nil
        mockDependencyManager = nil
        cancellables = []
        super.tearDown()
    }
    
    func testStartUserNotif_SchedulesDailyNotificationWithFetchedWeather() {
        let expection = XCTestExpectation(description: "Location")
        let expectedWeather = FakeWeatherCurrentInfo.fakeCurrentInfo(name: "Testx")

        mockNetworkManager.stubbedResponse = expectedWeather
        viewModel.startUserNotif(task: MockBGTask())
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.mockNetworkManager.request is CurrentWeatherRequest)
            XCTAssertTrue(self.mockLocationService.startedTracking)
            XCTAssertNotNil(self.mockNotificationFactory.weather?.name)
            XCTAssertEqual(self.mockNotificationFactory.weather!.name, expectedWeather.name)
            expection.fulfill()
        }
        wait(for: [expection], timeout: 1)
    }
}
