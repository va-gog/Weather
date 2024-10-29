//
//  UserInfoTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import XCTest
@testable import Weather

class UserInfoTests: XCTestCase {

    var userInfo: UserInfo!

    override func setUp() {
        super.setUp()
        userInfo = UserInfo(id: "testUser")
    }

    override func tearDown() {
        userInfo = nil
        super.tearDown()
    }

    func testUpdateObject() {
        let latitude = 37.7749
        let longitude = -122.4194
        let storeInfo = StoreCoordinates(latitude: latitude,
                                         longitude: longitude,
                                         index: 0)

        userInfo.updateObject(storeInfo: storeInfo)

        XCTAssertEqual(userInfo.coordinates.count, 1)
        XCTAssertEqual(userInfo.coordinates.first?.longitude, longitude)
        XCTAssertEqual(userInfo.coordinates.first?.latitude, latitude)
    }

    func testFetchStoredCoordinates() {
        let latitude = 37.7749
        let longitude = -122.4194
        userInfo.coordinates.append(StoreCoordinates(latitude: latitude, longitude: longitude, index: 0))

        let fetchedCoordinates = userInfo.fetchStoredCoordinates()

        XCTAssertEqual(fetchedCoordinates.count, 1)
        XCTAssertEqual(fetchedCoordinates.first?.lon, longitude)
        XCTAssertEqual(fetchedCoordinates.first?.lat, latitude)
    }
}
