//
//  StorageManagerTests.swift
//  WeatherTests
//
//  Created by Gohar Vardanyan on 23.10.24.
//

import XCTest
@testable import Weather

class StorageManagerTests: XCTestCase {
    var storageService: StorageService!
    var mockStorage: MockStorage!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockStorage()
        storageService = StorageService(storage: mockStorage)
    }
    
    override func tearDown() {
        mockStorage = nil
        storageService = nil
        super.tearDown()
    }
    
    
    func testAddNewItemSuccess() {
        let testInfo = StoreCoordinates(latitude: 10, longitude: 10, index: 0)
        let testId = "uniqueId123"
        let testUser = UserInfo(id: testId)
        
        let result = storageService.addItem(info: testInfo,
                                                    type: UserInfo.self,
                                                    object: testUser)
        if case .failure(let error) = result {
            XCTFail("Failed to add item with error: \(error)")
        }
        
        XCTAssertEqual(mockStorage.storedObjects.count, 1)
        XCTAssertEqual(mockStorage.storedObjects.first?.id, testId)
    }
    
    func testAddNewItemFailure() {
        mockStorage.failure = .add
        
        let result = storageService.addItem(info: StoreCoordinates(latitude: 10, longitude: 10, index: 0),
                                                    type: UserInfo.self,
                                                    object: UserInfo(id: "uniqueId"))
        switch result {
        case .success:
            XCTFail("Expected failure, but succeeded.")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }
    
    func testUpdateItemSuccess() {
        let testInfo = StoreCoordinates(latitude: 10, longitude: 10, index: 0)
        let testId = "uniqueId123"
        let testUser = UserInfo(id: testId)
        mockStorage.storedObjects.append(testUser)
        
        let result = storageService.addItem(info: testInfo,
                                                    type: UserInfo.self,
                                                    object: testUser)
        
        if case .failure(let error) = result {
            XCTFail("Failed to add item with error: \(error)")
        }
        
        XCTAssertTrue(mockStorage.storedObjects.contains { $0.id == testId })
    }

    func testUpdateItemFailure() {
        mockStorage.failure = .write
        let testInfo = StoreCoordinates(latitude: 10, longitude: 10, index: 0)
        let testId = "uniqueId123"
        let testUser = UserInfo(id: testId)
        mockStorage.storedObjects.append(testUser)
        
        let result = storageService.addItem(info: testInfo,
                                                    type: UserInfo.self,
                                                    object: testUser)
        
        switch result {
        case .success:
            XCTFail("Expected failure, but succeeded.")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }
    
    func testFetchExistingItem() {
        let testId1 = "uniqueId1"
        let testId2 = "uniqueId2"

        mockStorage.storedObjects.append(UserInfo(id: testId1))
        mockStorage.storedObjects.append(UserInfo(id: testId2))

        
        let fetchedUser = storageService.fetchItem(byId: testId2,
                                                   type: UserInfo.self) as? UserInfo
        
        XCTAssertNotNil(fetchedUser)
        XCTAssertEqual(fetchedUser?.id, testId2)
    }


}
