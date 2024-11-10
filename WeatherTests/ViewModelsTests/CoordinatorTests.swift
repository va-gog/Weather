//
//  CoordinatorTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 10.11.24.
//

import XCTest
@testable import Weather

final class CoordinatorTests: XCTestCase {
    var coordinator: Coordinator!

    override func setUp() {
        super.setUp()
        coordinator = Coordinator(dependenciesManager: MockDependencyManager())
    }

    override func tearDown() {
        coordinator = nil
        super.tearDown()
    }

    @MainActor
    func testPushPage() {
        let expectation = self.expectation(description: "Push page")
        coordinator.push(page: .main)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            XCTAssertEqual(self.coordinator.path.count, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }

    @MainActor
    func testPopPage() {
        coordinator.path.append(AppPages.main)
        XCTAssertEqual(coordinator.path.count, 1)
        
        coordinator.pop(.last)
        XCTAssertTrue(coordinator.path.isEmpty)
    }

    @MainActor
    func testPopForecastWithClose() {
        coordinator.path.append(AppPages.forecast)
        XCTAssertEqual(coordinator.path.count, 1)
        
        coordinator.pop(.forecastClose)
        XCTAssertTrue(coordinator.path.isEmpty)
    }
    
    @MainActor
    func testSignOute() {
        coordinator.path.append(AppPages.main)
        coordinator.path.append(AppPages.forecast)

        XCTAssertEqual(coordinator.path.count, 2)
        
        coordinator.pop(.signOut)
        XCTAssertTrue(coordinator.path.isEmpty)
    }

}
