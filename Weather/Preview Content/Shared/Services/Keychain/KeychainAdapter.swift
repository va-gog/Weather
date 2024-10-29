//
//  KeychainAdapter.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import Foundation

struct KeychainAdapter: KeychainInterface {
    func saveItem(query: [String: Any]) -> Bool {
        let status = SecItemAdd(query as CFDictionary, nil)
        return status != errSecSuccess
        
    }
    
    func retrieveItem(query: [String: Any]) -> String? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
                let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }
}
