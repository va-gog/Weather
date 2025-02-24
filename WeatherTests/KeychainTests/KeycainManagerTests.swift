//
//  KeycainManagerTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import XCTest
@testable import Weather

class KeychainManagerTests: XCTestCase {
    var keychainManager: KeychainManager!
    @Dependency var mockKeychain: MockKeychain!
    
    override func setUp() {
        super.setUp()
        self._mockKeychain.injectMock(MockKeychain())
        keychainManager = KeychainManager(service: "test",
                                          keychain: mockKeychain)
    }
    
    override func tearDown() {
        super.tearDown()
        keychainManager = nil
        mockKeychain = nil
    }
    
    func testSaveItemSuccess() {
        let testKey = "testKey"
        let testData = "testValue".data(using: .utf8)
        do {
            try keychainManager.saveItem(data: testData,
                                         key: testKey,
                                         secClass: kSecClassGenericPassword)
            XCTAssertNotNil(mockKeychain.storage)
            XCTAssertEqual(mockKeychain.storage?[kSecAttrAccount as String] as! String  , testKey)
            XCTAssertEqual(mockKeychain.storage?[kSecClass as String] as! String, kSecClassGenericPassword as String)
            XCTAssertEqual(mockKeychain.storage?[kSecValueData as String] as? Data, testData)
            XCTAssertEqual(mockKeychain.storage?[kSecAttrService as String] as! String, "test")
        } catch {
            XCTFail("Save item failed with error: \(error)")
        }
    }
    
    func testSaveItemAddFailure() {
        let testKey = "testKey"
        let testData = "testValue".data(using: .utf8)
        mockKeychain.error = KeychainError.invalidData
        
        XCTAssertThrowsError(try keychainManager.saveItem(data: testData,
                                                          key: testKey,
                                                          secClass: kSecClassGenericPassword)) { error in
            XCTAssertTrue(error is KeychainError)
            XCTAssertEqual(error as? KeychainError, KeychainError.invalidData)
        }
    }
    
    func testSaveItemEmptyDataFailure() {
        let testKey = "testKey"
        
        XCTAssertThrowsError(try keychainManager.saveItem(data: nil,
                                                          key: testKey,
                                                          secClass: kSecClassGenericPassword)) { error in
            XCTAssertTrue(error is KeychainError)
            XCTAssertEqual(error as? KeychainError, KeychainError.invalidData)
        }
    }
    
    func testRetrieveItem_success() {
        let testKey = "testKey"
        
        do {
            let retrievedValue = try keychainManager.retrieveItem(key: testKey,
                                                                  secClass: kSecClassGenericPassword)
            XCTAssertEqual(retrievedValue, testKey)
        } catch {
            XCTFail("Retrieve item failed with error: \(error)")
        }
    }
    
    func testRetrieveItem_failure() {
        let testKey = "testKey"
        mockKeychain.retrieveSucceed = false
        
        XCTAssertThrowsError(try keychainManager.retrieveItem(key: testKey,
                                                              secClass: kSecClassGenericPassword)) { error in
            XCTAssertTrue(error is KeychainError)
            XCTAssertEqual(error as? KeychainError, KeychainError.itemNotFound)
        }
    }
}
