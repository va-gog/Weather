//
//  MockKeychain.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import Foundation
@testable import Weather

class MockKeychain: KeychainInterface {
    
    var storage: [String: Any]?
    var error: KeychainError?
    var retrieveSucceed = true
    
    func saveItem(query: [String : Any]) throws {
        if let error { throw error }
        storage = query
    }
    
    func retrieveItem(query: [String: Any]) -> String? {
        if !retrieveSucceed { return nil}

       return query[kSecAttrAccount as String] as? String
    }
}

