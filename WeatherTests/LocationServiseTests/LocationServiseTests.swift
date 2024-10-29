//
//  LocationServiseTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import XCTest
import Combine
import CoreLocation
@testable import Weather

class LocationServiceTests: XCTestCase {
    private var locationService: LocationService!
    private var mockLocationManager: MockLocationManager!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockLocationManager = MockLocationManager()
        locationService = LocationService(manager: mockLocationManager)
        cancellables = []
    }

    override func tearDown() {
        mockLocationManager = nil
        locationService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testStartUpdatingLocationIs() {
        let expectation = XCTestExpectation(description: "Start location updates")
        locationService.startTracking()

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockLocationManager.started)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testDidUpdateLocationEmptyResult() {
        let expectation = XCTestExpectation(description: "Start location updates")

        locationService.latestLocationObject
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Should fail")
                case .failure(let error):
                    XCTAssertEqual(error, LocationError.noLocationAvailable)
                }
                expectation.fulfill()
            },
                  receiveValue: { location in
            })
            .store(in: &cancellables)
        locationService.locationManager(CLLocationManager(), didUpdateLocations: [])

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDidUpdateLocationSuccess() {
        let expectation = XCTestExpectation(description: "Start location updates")

        locationService.latestLocationObject
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Should fail")
                    expectation.fulfill()

                case .failure(let error):
                    XCTAssertEqual(error, LocationError.noLocationAvailable)
                    expectation.fulfill()
                }
                expectation.fulfill()
            }, receiveValue: { location in
            })
            .store(in: &cancellables)
        locationService.locationManager(CLLocationManager(), didFailWithError: NSError(domain: "", code: 0))

        wait(for: [expectation], timeout: 1.0)
    }

    func testLocationManagerAuthorizationStatusChangeAuthorized() {
        let expectation = XCTestExpectation(description: "Authorization status should change")
        let expectedStatus = LocationAuthorizationStatus.authorized
        locationService.statusSubject
            .sink(receiveValue: { status in
                XCTAssertEqual(status, expectedStatus)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        locationService.locationManager(CLLocationManager(), didChangeAuthorization: .authorizedAlways)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLocationManagerAuthorizationStatusChangeDenied() {
        let expectation = XCTestExpectation(description: "Authorization status should change")
        let expectedStatus = LocationAuthorizationStatus.denied
        locationService.statusSubject
            .sink(receiveValue: { status in
                XCTAssertEqual(status, expectedStatus)
                expectation.fulfill()
            })
            .store(in: &cancellables)
            
        locationService.locationManager(CLLocationManager(), didChangeAuthorization: .denied)
        wait(for: [expectation], timeout: 1.0)
    }
}
