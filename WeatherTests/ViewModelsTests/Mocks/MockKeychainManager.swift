//
//  MockKeychainManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import Foundation
@testable import Weather

final class MockKeychainManager: KeychainManagerInterface {
    var password: String?
    var email: String?
    var secClass: CFString?
    
    func saveItem(data: Data?, key: String, secClass: CFString) throws {
        email = key
        password = String(data: data ?? Data(), encoding: .utf8)
        self.secClass = secClass
    }
    
    func retrieveItem(key: String, secClass: CFString) throws -> String {
        guard let password else {
            throw KeychainError.emptyData
        }
        
        return password
    }
}
