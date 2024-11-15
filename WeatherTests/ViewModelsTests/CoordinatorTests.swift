//
//  AppLaunchScreenCoordinatorTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 10.11.24.
//

import XCTest
@testable import Weather

final class AppLaunchScreenCoordinatorTests: XCTestCase {
    var coordinator: AppLaunchScreenCoordinator!
    var mockDependencyManager: MockDependencyManager!

    override func setUp() {
        super.setUp()
        mockDependencyManager = MockDependencyManager()
        coordinator = AppLaunchScreenCoordinator(dependenciesManager: mockDependencyManager)
    }

    func testPushPage() {
        coordinator.push(page: .locationAccess)
        XCTAssertEqual(coordinator.childs.count, 1)
        XCTAssertEqual(coordinator.path.count, 1)
        XCTAssertEqual(coordinator.childs.first?.type, .locationAccess)
        
        coordinator.push(page: .main)
        XCTAssertEqual(coordinator.childs.count, 1)
        XCTAssertEqual(coordinator.path.count, 1)
        XCTAssertEqual(coordinator.childs.first?.type, .main)
    }
    
    func testPopPage() {
        coordinator.push(page: .locationAccess)
        XCTAssertEqual(coordinator.childs.count, 1)
        XCTAssertEqual(coordinator.path.count, 1)
        XCTAssertEqual(coordinator.childs.first?.type, .locationAccess)
        
        coordinator.pop(pages: [.locationAccess])
        XCTAssertEqual(coordinator.childs.count, 0)
        XCTAssertEqual(coordinator.path.count, 0)
    }
}
