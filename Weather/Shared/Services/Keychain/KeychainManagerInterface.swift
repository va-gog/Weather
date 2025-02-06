//
//  KeychainManagerInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import Foundation

protocol KeychainManagerInterface {
    func saveItem(data: Data?, key: String, secClass: CFString) throws
    func retrieveItem(key: String, secClass: CFString) throws -> String
}
