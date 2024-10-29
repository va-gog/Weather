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
    var saveSucceed = true
    var retrieveSucceed = true
    
    func saveItem(query: [String: Any]) -> Bool {
        if !saveSucceed { return false}
        storage = query
        
        return true
    }
    
    func retrieveItem(query: [String: Any]) -> String? {
        if !retrieveSucceed { return nil}

       return query[kSecAttrAccount as String] as? String
    }
}

