//
//  KeychainAdapter.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import Foundation

struct KeychainAdapter: KeychainInterface {
    
    func saveItem(query: [String: Any]) throws  {
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError.unknownError(status: status)
        }
    }
    
    func retrieveItem(query: [String: Any]) throws -> String? {
        var item: CFTypeRef?
        
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        switch status {
        case errSecSuccess:
            if let data = item as? Data, let value = String(data: data, encoding: .utf8) {
                return value
            } else {
                throw KeychainError.invalidData
            }
            
        case errSecItemNotFound:
             throw KeychainError.itemNotFound
            
        default:
             throw KeychainError.unknownError(status: status)
        }
    }
}
