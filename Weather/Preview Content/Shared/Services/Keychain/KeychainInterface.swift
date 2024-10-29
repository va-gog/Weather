//
//  KeychainInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

protocol KeychainInterface {
    func saveItem(query: [String: Any]) -> Bool
    func retrieveItem(query: [String: Any]) -> String?
}
