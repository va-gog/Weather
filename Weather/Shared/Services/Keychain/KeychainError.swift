//
//  KeychainError.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import Foundation

enum KeychainError: Error, Equatable {
    case itemNotFound
    case itemAddFail
    case invalidData
    case unknownError(status: OSStatus)
}
