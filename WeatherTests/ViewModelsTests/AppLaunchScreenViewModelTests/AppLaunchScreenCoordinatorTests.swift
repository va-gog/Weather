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

    override func setUp() {
        super.setUp()
        coordinator = AppLaunchScreenCoordinator()
    }
    
    override func tearDown() {
        super.tearDown()
        coordinator = nil
    }

    func testPushPage() {
        coordinator.push(WeatherAppScreen.locationAccess)
        XCTAssertEqual(coordinator.childs.count, 1)
        XCTAssertEqual(coordinator.path.count, 1)
        XCTAssertEqual(coordinator.childs.first?.type as? WeatherAppScreen, WeatherAppScreen.locationAccess)
        
        coordinator.push(WeatherAppScreen.main)
        XCTAssertEqual(coordinator.childs.count, 1)
        XCTAssertEqual(coordinator.path.count, 1)
        XCTAssertTrue(coordinator.childs.last?.reducer is MainScreenViewModel)
        XCTAssertEqual(coordinator.childs.last?.type as? WeatherAppScreen, WeatherAppScreen.main)
    }
    
    func testPopPage() {
        coordinator.push(WeatherAppScreen.locationAccess)
        XCTAssertEqual(coordinator.childs.count, 1)
        XCTAssertEqual(coordinator.path.count, 1)
        XCTAssertEqual(coordinator.childs.first?.type as? WeatherAppScreen, WeatherAppScreen.locationAccess)
        
        coordinator.pop([WeatherAppScreen.locationAccess])
        XCTAssertEqual(coordinator.childs.count, 0)
        XCTAssertEqual(coordinator.path.count, 0)
    }
    
    func testCoordinatorViewBuilder() {
        let empty = coordinator.build(screen: WeatherAppScreen.main)
        XCTAssertNil(empty)

        coordinator.push(WeatherAppScreen.main)
        let mainView = coordinator.build(screen: WeatherAppScreen.main)
        XCTAssertNotNil(mainView)
        
        coordinator.push(WeatherAppScreen.locationAccess)
        let locationView = coordinator.build(screen: WeatherAppScreen.locationAccess)
        XCTAssertNotNil(locationView)
    }
}
