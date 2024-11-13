//
//  KeychainManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 27.10.24.
//
import Foundation

// TODO: Remove query init into factory

class KeychainManager: KeychainManagerInterface {
    private let service: String
    private var keychain: KeychainInterface
    
    init(keychain: KeychainInterface = KeychainAdapter(),
         service: String = "com.default.identifier") {
        self.keychain = keychain
        self.service = service
    }
    
    func saveItem(data: Data?, key: String, secClass: CFString) throws {
        guard let data else {
            throw KeychainError.invalidData
        }
        
        let query: [String: Any] = [
            kSecClass as String: secClass,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "\(key)",
            kSecValueData as String: data
        ]
        
        try keychain.saveItem(query: query)
    }
    
    func retrieveItem(key: String, secClass: CFString) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: secClass,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "\(key)",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        guard let value =  try keychain.retrieveItem(query: query) else {
            throw KeychainError.itemNotFound
        }
        
        return value
    }
}
